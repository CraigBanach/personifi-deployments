# TCG Medusa Production Runbook

The Personifi host reconciles only the tracked production manifest, and only when that file changes. Unrelated commits in this shared GitOps repository do not restart or update Free Splash:

```text
environments/tcg-medusa-production.env
```

Production uses Nomad jobs named `tcg-medusa-production*`, variables beneath `tcg-store/medusa/production/*`, production-qualified generated job files and Traefik names, the ignored `.tcg-medusa-production.secrets.env` file, and `/opt/tcg-medusa/production` state. Deployment scripts reject non-production environments and any hostname other than `freesplash.co.uk`, `www.freesplash.co.uk`, and `api.freesplash.co.uk`.

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

Run the production deployment manually as `gitops`:

```bash
sudo -u gitops bash /opt/personifi-deployments/scripts/quick-deploy-tcg-medusa.sh
```

Config batch jobs purge the previous production-qualified job and wait for a successful allocation. A merely terminal job is not treated as successful.
