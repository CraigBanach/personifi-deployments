# One-off storefront price-cache release — 8 November 2026

## Approval and limits

The operator explicitly approved a one-off manual GitOps promotion after GitHub
Actions billing prevented the normal protected workflow from completing. This
is an exception for this release, not a replacement for the workflow-only rule.

- Frozen source reachable from application `main`:
  `ff0e3d1715ff5319218074ef2ef71bca5e487e12`.
- Storefront only. Later inventory/acquisition commits are outside this release.
- Preserve the running backend image and its migration receipt. No migrations,
  catalog/config application, payment tests, subscription changes or email sends.
- Customer marketing/campaign release remains on hold, including Brevo drafts
  11 and 12. This application rollout does not authorize customer communications.

## Immutable artifacts

| Component | Image |
| --- | --- |
| New storefront | `ghcr.io/craigbanach/tcg-store-storefront@sha256:cfddf8b5eb576a67fc2ae368e09ec02154aa525d72891c3996cad36236270aae` |
| Preserved backend | `ghcr.io/craigbanach/tcg-store-backend@sha256:04710fc8ae9619413c508dc2d53ea2264e03244a675c0e480512c614ad7f5687` |
| Previous storefront / rollback | `ghcr.io/craigbanach/tcg-store-storefront@sha256:8b53e761ad27e58c846b0b57f4b873ee4178fed6eb1f453b0a085301961aea65` |

The backend remains at source `c44fdd074569e78eb0bf868eb58128bcd5295a80`;
the manifest's new source SHA describes the newly built storefront, not a
backend rebuild.

Canonical LF source archive SHA-256:
`9ea5bcc56beaf92cac960f63ced0a5b416eaddf5d48224aaf266deea469fa249`.
Frozen validation workflow SHA-256:
`7557f38413a3d05acff7a517a01c3fd4be964847c15880310588d2cdfa00134a`.

The source archive, not a dirty working tree, is used for both validation and
the Linux/amd64 Docker build. The ordinary tracked storefront Dockerfile is
used, including production compilation, lint, types and standalone packaging.
The image is non-root. An isolated network-disabled/read-only container proved
its release SHA/digest and preserved Stripe/PostHog public bundle configuration.
No production credentials were sent to the isolated validation VM.

## Compatibility and rollout controls

Compared with the live source, storefront changes are the calculated-price and
authoritative-cart read cache fix, its tests, and the already-approved category
best-seller default. Backend Store API routes/workflows/subscribers and shared
dependency manifests do not change between the live and frozen source. Live
uncached anonymous UK/GBP calculated prices were verified as 164.99, 314.99 and
214.99 for Zendikar, LOTR and Journey Together respectively, without price-list
overrides and using the same storefront sales-channel key.

The live migration receipt was read without network access or database access
and matches the preserved backend digest. The GitOps scripts/templates are
unchanged from the last live promotion. Digest-derived per-app task identity
and the matching receipt mean this storefront-only rollout neither replaces
the backend/Redis task group nor runs a migration batch.

Keep `TCG_MEDUSA_MANAGED_ROLLOUT=true`, `TCG_MEDUSA_RUN_CONFIG=false` and
`TCG_MEDUSA_RUN_CATALOG=false`; preserve all other runtime flags and credentials.
Only the ordinary production manifest is promoted, plus this audit record.

## Validation gate

Full isolated Linux validation passed for the frozen SHA/archive on
8 November, 05:40:45–06:06:54 UTC. Every phase and the final exit were zero:

| Phase | Exit | Seconds |
| --- | --- | --- |
| Frozen dependency install | 0 | 48 |
| Source lint/types/unit checks | 0 | 241 |
| Fresh database, builds, SQL/email/marketing and browser checks | 0 | 588 |
| Standard multichannel partition | 0 | 424 |
| Recovery multichannel partition | 0 | 267 |
| Complete/nonoverlapping proof inventory | 0 | 1 |

Backend units: 3,837 passed, zero failed; existing 25 pending/4 TODO counts
retained. Multichannel inventory: all 617 non-TODO cases passed exactly once
(445 standard, 172 recovery), plus two existing TODOs. Browser results:
101 read-only and 38 stateful passes, zero failures or flaky cases. Two existing
conditional browser skips remain: real Stripe initialization (not configured in
the disposable environment) and the optional authenticated eBay Admin test.
Neither is part of the price regression, which passed without a skip.

The actual price-edit browser regression verified the calculated Store API,
public detail and request-context buy controls, listing/related cards, the same
warm cache cookie, a fresh session, and basket/checkout after normal line-item
recalculation/new additions. No server restart or cookie clearing occurred
between the price edit and verification; no payment/order was made.

Root-owned retained evidence:
`/srv/freesplash-ci/admin/benchmark-20261108T054006Z` on the isolated validation
host, with a downloaded copy in the approved operator temporary directory
`storefront-manual-release-20261108`. The archive/source identities and every
phase/report were checked before promotion. VM isolation passed and its
disposable guest was destroyed after evidence collection. Failed earlier
Windows diagnostics and failed GitHub runs are not release evidence.

## Public verification and rollback

### Verification failure and storefront-only rollback

Promotion `ce2d45e77c3c5137f881e7f04fb4fb8eaade711f` initially passed
three consecutive exact-digest/public health checks. Follow-up price checks
then encountered intermittent public HTTP 503 `no available server` responses.
Nomad reported a running, healthy new storefront with no task restarts and
an unchanged backend allocation. Independent Node/curl requests also reproduced
an intermittent 503, so this was not dismissed as a PowerShell-client issue.

The managed rollout's Nomad and Traefik storefront probes both render `/gb`
every five seconds with three-second timeouts. The uncached price-bearing
homepage queries may make that probe path exceed its budget; this is a
hypothesis for the underlying rendering cost. Sanitized Traefik diagnostics
confirmed **39 storefront probe timeouts**, from 06:11:59 to 06:19:04 UTC,
explaining the service's health-check flapping. No raw customer/access logs were
returned. No health-check bypass or resource change was made to hide the failure.

At 06:16:58 UTC the operator-authorized recovery procedure selected the previous
storefront digest through a new GitOps rollback commit. Backend digest, all
runtime flags, migration receipt and customer-release hold remain unchanged.
The new image stays published and its successful isolated validation evidence
is retained, but the price-cache fix must not be described as successfully
released.

Rollback commit: `4a27227bc9c030f69d4d49c3d272a3b370573958`. Nomad deployment
`d315cbb7` completed successfully. The previous storefront source/digest was
read back publicly and both digest endpoints, API health and `/gb` passed
12 consecutive checks. Restored storefront allocation: `dcf8c200`; backend
allocation remains `e14abdfc`, unchanged throughout promotion and rollback.
The rollout/rollback did not run a migration or restart backend/Redis.

The price fix is **not live**. A proposed follow-up is to use the lightweight
uncached `/api/release` for storefront service probes while retaining `/gb`
and the exact-digest/API-health business checks as promotion verification.
That health-check change has not been applied and needs explicit review/approval.

After GitOps reconciliation, require both exact expected image digests, API
health and `/gb` to pass three consecutive uncached checks. Verify storefront
source is the frozen SHA and backend source/digest/allocation is unchanged.
Recheck product/buy controls, listing cards and related cards in the saved
pre-rollout anonymous session and a fresh session, against uncached UK Store
API calculated prices. Do not create customer carts/payments in production.

The isolated price-edit test must also distinguish stored pre-edit basket
prices from stale fetches: existing line items retain their stored price until
normal cart recalculation. This release does not silently mutate cart prices or
payment sessions. Basket/checkout freshness after normal recalculation and new
additions is verified in the disposable test environment.

If rollback is needed, make a new GitOps commit restoring the previous
storefront digest and its appropriate release metadata, while leaving the
backend digest and runtime flags unchanged. Retain this audit record and the
failed rollout evidence. Do not roll back the database, hot-patch a container,
or overwrite a concurrent operator's manifest changes.
