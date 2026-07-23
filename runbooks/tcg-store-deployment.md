# TCG Store Deployment Runbook

## Purpose

Deploy Craig's Cards / TCG Store to the existing single-node Nomad and Traefik box.

The first live version intentionally uses the stock nopCommerce image and default theme. Custom theme work can restart later after the store is installed, backed up, and reachable.

## Server Secrets

Create `/opt/personifi-deployments/.tcg-store.secrets.env` as the `gitops` user.

```bash
TCG_DATABASE_CONNECTION_STRING_DIRECT="Host=...;Port=5432;Database=...;Username=...;Password=...;SSL Mode=Require;Trust Server Certificate=true;"
TCG_DATABASE_CONNECTION_STRING_POOLED="Host=...;Port=5432;Database=...;Username=...;Password=...;SSL Mode=Require;Trust Server Certificate=true;"
TCG_DATABASE_URL_DIRECT="postgresql://user:password@host/database?sslmode=require"
TCG_IMAGE="nopcommerceteam/nopcommerce:4.80.7"
```

Do not commit real values.

`TCG_DATABASE_CONNECTION_STRING_DIRECT` and `TCG_DATABASE_CONNECTION_STRING_POOLED` are .NET-style connection strings for nopCommerce/admin usage. `TCG_DATABASE_URL_DIRECT` is a libpq-style URL for `pg_dump`. If the provider has no connection pooler, set `DIRECT` and `POOLED` to the same value.

## Persistent Directories

The quick deploy script creates these directories:

```bash
/opt/tcg-store/data-protection-keys
/opt/tcg-store/images
/opt/tcg-store/images/uploaded
/opt/tcg-store/images/thumbs
/opt/tcg-store/files
/opt/tcg-store/icons
/opt/tcg-store/plugins
/opt/tcg-store/backups/postgres
/opt/tcg-store/backups/media
/opt/tcg-store/appsettings.json
/opt/tcg-store/plugins.json
```

`/opt/tcg-store/images/uploaded` is required by nopCommerce Roxy Fileman (`FILES_ROOT=/images/uploaded`). If it is missing under the persisted images mount, installation can fail while activating `RoxyFilemanFileProvider`.

`/opt/tcg-store/images/thumbs` is required by nopCommerce picture upload/thumbnail generation. If it is missing under the persisted images mount, admin image uploads can fail in `Admin/Picture/AsyncUpload`.

`/opt/tcg-store/icons` persists generated favicons and store icons from `/app/wwwroot/icons`.

`/opt/tcg-store/plugins.json` persists nopCommerce plugin install state. If it is not persisted, clicking Install on a plugin appears to work, but the install is lost after the nopCommerce restart.

`/opt/tcg-store/plugins` stores third-party plugin files that are not bundled in the stock nopCommerce image. The Nomad job currently mounts the NopStation Stripe plugin folders into `/app/Plugins`:

```bash
/opt/tcg-store/plugins/NopStation.Core
/opt/tcg-store/plugins/NopStation.Plugin.Payments.Stripe
```

Install a plugin ZIP on the server with:

```bash
sudo -u gitops bash /opt/personifi-deployments/scripts/install-tcg-plugin-zip.sh /tmp/NopStation.Plugin.Payments.Stripe-4.80.zip
```

Use a plugin package that matches the nopCommerce major/minor version. The current image is `nopcommerceteam/nopcommerce:4.80.7`, so use a 4.80 plugin build.

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
3. Use the managed Postgres host, database, username, and password.
4. Leave `Create database if it doesn't exist` unchecked for managed providers such as Aiven or Neon.
5. Leave sample data unchecked unless deliberately testing demo catalog content.
6. Complete install and let nopCommerce restart itself.
7. Keep the default nopCommerce theme until the store is stable.

Before retrying a failed install against managed Postgres, reset the schema and extension:

```sql
DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
CREATE EXTENSION IF NOT EXISTS citext;
```

The current staging database was migrated from Neon to Aiven Free PostgreSQL because nopCommerce scheduled tasks kept Neon compute active. Aiven Free has no pooler, so the direct and pooled connection strings are identical.

## Database Migration

Use a custom-format dump and restore when moving providers:

```bash
pg_dump "$SOURCE_DATABASE_URL" --format=custom --no-owner --no-acl --file=/tmp/tcg-store.dump
psql "$TARGET_DATABASE_URL" -c 'DROP SCHEMA IF EXISTS public CASCADE;' -c 'CREATE SCHEMA public;' -c 'CREATE EXTENSION IF NOT EXISTS citext;'
pg_restore "--dbname=$TARGET_DATABASE_URL" --no-owner --no-acl --clean --if-exists /tmp/tcg-store.dump
```

After updating `/opt/personifi-deployments/.tcg-store.secrets.env`, run `scripts/configure-tcg-nopcommerce.sh` to update `/opt/tcg-store/appsettings.json`, then restart the Nomad job.

## Backup

Install `postgresql-client` on the host if `pg_dump` is missing.

```bash
sudo -u gitops /opt/personifi-deployments/scripts/backup-tcg-store.sh
```

Schedule it with systemd timer or cron only after a manual backup and restore test succeeds.
