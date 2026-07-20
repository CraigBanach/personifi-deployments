# TCG Store Deployment Runbook

## Purpose

Deploy Craig's Cards / TCG Store to the existing single-node Nomad and Traefik box.

The first live version intentionally uses the stock nopCommerce image and default theme. Custom theme work can restart later after the store is installed, backed up, and reachable.

## Server Secrets

Create `/opt/personifi-deployments/.tcg-store.secrets.env` as the `gitops` user.

```bash
TCG_DATABASE_CONNECTION_STRING_DIRECT="Host=...;Port=5432;Database=...;Username=...;Password=...;SSL Mode=Require;Trust Server Certificate=true;"
TCG_DATABASE_CONNECTION_STRING_POOLED="Host=...-pooler...;Port=5432;Database=...;Username=...;Password=...;SSL Mode=Require;Trust Server Certificate=true;"
TCG_DATABASE_URL_DIRECT="postgresql://user:password@host/database?sslmode=require"
TCG_IMAGE="nopcommerceteam/nopcommerce:4.80.7"
```

Do not commit real values.

`TCG_DATABASE_CONNECTION_STRING_DIRECT` and `TCG_DATABASE_CONNECTION_STRING_POOLED` are .NET-style connection strings for nopCommerce/admin usage. `TCG_DATABASE_URL_DIRECT` is a libpq-style URL for `pg_dump`.

## Persistent Directories

The quick deploy script creates these directories:

```bash
/opt/tcg-store/app-data
/opt/tcg-store/images
/opt/tcg-store/backups/postgres
/opt/tcg-store/backups/media
```

## Deploy

### Manual Deploy

```bash
sudo -u gitops bash /opt/personifi-deployments/scripts/quick-deploy-tcg-store.sh
nomad job status tcg-store
```

### GitOps Deploy

TCG is wired into the existing GitOps poller but guarded by `TCG_ENABLED` in `deployment.env`.

Keep it disabled while DNS/cert setup is incomplete:

```bash
TCG_ENABLED=false
```

Enable it when the desired hostnames point at the Hetzner box:

```bash
TCG_ENABLED=true
TCG_IMAGE=nopcommerceteam/nopcommerce:4.80.7
```

The existing `gitops-deploy.timer` will pull `origin/main` and deploy TCG when `deployment.env` changes on `main`.

## Install nopCommerce

The first pass intentionally uses the normal nopCommerce installer rather than automating secret injection into nopCommerce settings.

1. Visit `https://craigscards.co.uk/install` after DNS and Traefik are ready.
2. Select PostgreSQL.
3. Use the direct Neon host, database, username, and password.
4. Complete install.
5. Restart the Nomad job.
6. Keep the default nopCommerce theme until the store is stable.

## Backup

Install `postgresql-client` on the host if `pg_dump` is missing.

```bash
sudo -u gitops /opt/personifi-deployments/scripts/backup-tcg-store.sh
```

Schedule it with systemd timer or cron only after a manual backup and restore test succeeds.
