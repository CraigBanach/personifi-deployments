# TCG Medusa Production Runbook

The Personifi host reconciles the production manifest and its deployment helpers/templates. A receipt in `.git/tcg-successful-inputs` is written only after successful reconciliation, so failures retry without needing another commit. Unrelated commits in this shared GitOps repository do not restart or update Free Splash:

```text
environments/tcg-medusa-production.env
```

Production uses Nomad jobs named `tcg-medusa-production*`, variables beneath `tcg-store/medusa/production/*`, production-qualified generated job files and Traefik names, the ignored `.tcg-medusa-production.secrets.env` file, and `/opt/tcg-medusa/production` state. Deployment scripts reject non-production environments and any hostname other than `freesplash.co.uk`, `www.freesplash.co.uk`, and `api.freesplash.co.uk`.

## Managed rollout and migration recovery

New application promotions set `TCG_MEDUSA_MANAGED_ROLLOUT=true`. The default is
false for older images/installations; publishing these deployment scripts alone
does not opt existing images into managed migrations or change their group layout.

- The reconciler locks `/opt/gitops/reconcile.lock`; every TCG deployment also
  locks `/opt/gitops/tcg-medusa-rollout.lock` across migration and readiness.
- First adoption must rebuild **both** images with release-identity endpoints and
  managed-startup support. It requires an existing Redis answering PING on
  `172.17.0.1:6379`; this is not a fresh-install bootstrap. Do not start a second
  Redis against the persistence directory. Existing backend/Redis group name,
  Redis networking and state volumes are retained. Moving storefront to its own
  group causes a one-time allocation transition; subsequent frontend-only changes
  leave the backend/Redis group unchanged.
- `tcg-medusa-production-migrate` uses the exact backend image, auth, resources,
  environment and secret templates, but no public ports, services or state mounts.
  It runs only `pnpm predeploy`, without restart/reschedule retries; variable
  changes do not restart it. If Nomad ACLs are enabled, authorize this job's
  workload identity to read the same required variable paths as the backend—do
  not grant cluster-wide access. Missing access fails closed before service rollout.
- Successful migration records the backend image in
  `/opt/tcg-medusa/production/migrated-backend-image`. Storefront-only releases
  and service-rollout retries do not rerun it. If the database is intentionally
  replaced, review/remove that receipt before rollout; it applies to this database.
- A timed-out batch may still be alive: retries wait for the same image rather
  than replacing/restarting it. A failed batch is retained and blocks automatic
  replay. Inspect `nomad job status tcg-medusa-production-migrate` and its
  allocation logs, review actual database effects, and resolve/complete the
  migration before explicitly purging the batch to permit another attempt.
  Never purge a live migration just to bypass the gate.
- Migrations run while the old application serves traffic; use backward-compatible
  expand/contract schema changes. No automatic database rollback is attempted.
- Backend and storefront HTTP checks gate Nomad rollout; Traefik also checks
  readiness. Public exact-digest identity plus `/health` and `/gb` must succeed
  three consecutive times before managed reconciliation is marked successful.
  GitHub promotion independently verifies the same evidence after publishing the
  manifest. A committed manifest is desired state, not verified deployment.

Local tests: `python3 -m unittest discover -s scripts/tests -p 'test_*.py'` and
`GO111MODULE=off go test ./scripts/tests`. Parse the rendered HCL with
`nomad job run -output`, derive both JSON jobs using `tcg-managed-rollout.py`,
then validate each with `nomad job validate -json` before changing rollout logic.

On the first reconciliation, the deploy script moves the legacy `.tcg-medusa.secrets.env` file into its production-qualified location. Move root-owned state before retiring the legacy job:

```bash
sudo mkdir -p /opt/tcg-medusa/production
sudo mv /opt/tcg-medusa/redis /opt/tcg-medusa/production/
sudo mv /opt/tcg-medusa/static /opt/tcg-medusa/production/
sudo mv /opt/tcg-medusa/backups /opt/tcg-medusa/production/
```

The deployment script validates that move before it stops any legacy Nomad job.

## One-Time GitOps Bootstrap

The VPS timer invokes a copied reconciler at `/opt/gitops/gitops-deploy.sh`. It must be updated before this manifest workflow can take effect. After this repository commit is present in `/opt/personifi-deployments`, take and verify backups, then run:

```bash
sudo -u gitops bash /opt/personifi-deployments/scripts/bootstrap-tcg-medusa-production-gitops.sh
sudo -u gitops bash /opt/personifi-deployments/scripts/quick-deploy-tcg-medusa.sh
```

The second command performs the secret and Nomad-variable migration after the manual state move. Monitor it until `tcg-medusa-production` is healthy, then verify storefront, API, Admin, media, and checkout before treating the migration as complete.

`TCG_MEDUSA_RUN_CONFIG` independently controls store configuration. Production requires `TCG_MEDUSA_RUN_CATALOG=false`; catalog synchronization and listing intake are rejected. Backend and storefront images must be digest-pinned, and no image defaults are supplied.

## eBay Runtime Configuration

eBay values are backend runtime secrets, never image build arguments or tracked
deployment manifest values. Add them to the ignored
`/opt/personifi-deployments/.tcg-medusa-production.secrets.env` file, then run
the deployment command below. The script writes them to
`tcg-store/medusa/production/secrets`, and the backend Nomad task receives them
through its generated environment file.

```env
EBAY_API_BASE=https://api.ebay.com
EBAY_MARKETPLACE_ID=EBAY_GB
EBAY_LOCALE=en-GB
EBAY_CURRENCY=GBP
EBAY_LISTING_DURATION=GTC
EBAY_PRICE_MODE=buyer
EBAY_BUYER_PROTECTION_FIXED=0.10
EBAY_CLIENT_ID=
EBAY_CLIENT_SECRET=
EBAY_REDIRECT_URI=
EBAY_TOKEN_ENCRYPTION_KEY=
EBAY_DEV_ID=
EBAY_MERCHANT_LOCATION_KEY=
EBAY_CATEGORY_ID=183454
EBAY_FULFILLMENT_POLICY_ID=
EBAY_PAYMENT_POLICY_ID=
EBAY_RETURN_POLICY_ID=
EBAY_WEBHOOK_ENDPOINT=https://api.freesplash.co.uk/ebay/webhook
```

Use production eBay application, policy, and merchant-location values only.
Register the production RuName with `https://api.freesplash.co.uk/ebay/callback`.
Do not copy the Sandbox seller token or any Sandbox policy/location IDs.

For a direct Nomad variable update, use
`tcg-store/medusa/production/secrets`, not `tcg-store/medusa-secrets`. Nomad
keys are lower-case: `ebay_dev_id` maps to `EBAY_DEV_ID`, and
`ebay_webhook_endpoint` maps to `EBAY_WEBHOOK_ENDPOINT` in the backend task.

The VPS service `gitops-deploy.service` runs as `gitops` from `/opt/gitops`
every two minutes. A production-promotion manifest change re-renders the Nomad
job and replaces the backend allocation.

## Newsletter connection

Brevo credentials live only in `tcg-store/medusa/production/secrets`, under
`brevo_api_key`, `brevo_newsletter_list_id` and `brevo_webhook_secret`. The backend
template renders the corresponding uppercase environment variables. They are
not storefront settings or manifest values. Keep order/service/confirmation
SMTP on Purelymail; marketing welcome delivery belongs to Brevo automation.

The deployment script merges its settings with a fresh read of the existing
secret variable, preserving separately installed keys. The write uses the read
ModifyIndex as a compare-and-set condition, keeps preserved secrets in memory,
and suppresses secret output. A failed read or CAS stops deployment; never
replace this with a forced stale write. Initial secret-variable provisioning
must happen separately before this script can update it.

Template/script changes alone do not restart Free Splash. Merge them before
the approved application promotion updates the production manifest; the next
manifest reconciliation then renders the new template. Do not manually change
image digests or the manifest just to activate these mappings.

### Prospective customer marketing and Admin credentials

The backend-only template also maps `brevo_customer_marketing_list_id`,
`checkout_soft_opt_in_enabled`, `checkout_soft_opt_in_activated_at`,
`checkout_soft_opt_in_sales_channel_id`, `customer_marketing_approved_notice_version`
and `marketing_settings_encryption_key` from the same canonical secret variable.
Merge these template mappings before the application promotion. Use a fresh
compare-and-set merge to preserve every existing credential; never force-write
a stale secret snapshot. Missing optional keys render empty and do not activate enrolment.

Keep the customer list (6) separate from newsletter list 3 and welcome automation 1.
No historical/marketplace imports, customer welcome or campaign are part of setup.
Approval and activation belong to the application rollout record, not the GitOps manifest.
An explicit deployment `checkout_soft_opt_in_enabled=false` is an emergency hold
that takes precedence over Admin. Release that hold only for an approved prospective rollout.

Medusa Marketing → Customer marketing can manage non-secret settings and an
optional encrypted, write-only Brevo API-key override. Its separate encryption
master is a stable, randomly generated base64 32-byte secret, provisioned only
on the server. Back it up with the database; do not rotate it without migrating
encrypted overrides. Do not reuse cookie, webhook or eBay encryption secrets.
Blank Admin key input preserves the existing credential. Webhook/cookie secrets
remain deployment-only; ordinary Admin saves never replace canonical credentials.

Use the existing protected `promote-production.yml`, with `apply_store_config=false`.
For CI-only verification, provide a successful manually dispatched `Validate`
run ID on main for the exact source SHA, leaving `local_verified=false`.
Do not edit production image digests or bypass environment approval to install mappings.

Run the production deployment manually as `gitops`:

```bash
sudo -u gitops bash /opt/personifi-deployments/scripts/quick-deploy-tcg-medusa.sh
```

Config batch jobs purge the previous production-qualified job and wait for a successful allocation. A merely terminal job is not treated as successful.

## CardNexus connection

The CardNexus API key and webhook signing secret live only in
`tcg-store/medusa/production/secrets`, under `cardnexus_api_key` (`cnk_live_…`)
and `cardnexus_webhook_secret` (`whsec_…`), and render into the backend as
`CARDNEXUS_API_KEY` and `CARDNEXUS_WEBHOOK_SECRET`. Install them with
`set-tcg-secret.sh <key>` from an interactive terminal; deployments preserve
them. Everything else about the connection (creation, settings, mode) is done on
the Channels admin page. Without the key the connection cannot leave disabled;
without the webhook secret `POST /cardnexus/webhook` ignores deliveries and the
five-minute sale sweep still finds orders.
