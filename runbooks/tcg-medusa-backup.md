# TCG Medusa Backup Runbook

## Scope

The Medusa database contains product, image, cart, customer, and order records. Uploaded files live on the VPS at `/opt/tcg-medusa/static` and are mounted into the backend container.

Back up the database and static directory together. A media archive without the matching database may contain files that Medusa no longer references, while a database-only restore may reference missing files.

## Manual Backup

The backup uses `postgres:17-alpine` for `pg_dump` and `pg_restore`, avoiding mismatches with the managed PostgreSQL server. Docker must be available to the `gitops` user. Run:

```bash
sudo -u gitops bash /opt/personifi-deployments/scripts/backup-tcg-medusa.sh
```

The script:

- Reads the database URL from Nomad variable `tcg-store/medusa-database`.
- Runs the PostgreSQL 17 backup client in a short-lived Docker container.
- Creates a PostgreSQL custom-format dump.
- Creates a compressed archive containing the `static` directory.
- Verifies both archives before publishing them.
- Writes a SHA-256 manifest.
- Keeps 14 days locally by default.

Backups are written beneath `/opt/tcg-medusa/backups`.

Override retention with `RETENTION_DAYS`. Configure `RCLONE_REMOTE`, such as `b2:bucket/tcg-medusa`, to copy each completed backup off-host. Local backups protect against deployment mistakes but do not protect against VPS or disk loss, so an encrypted off-host remote is recommended.

## Enable Daily Backups

Run and inspect a manual backup before enabling the timer:

```bash
sudo install -m 0644 /opt/personifi-deployments/infra/systemd/tcg-medusa-backup.service /etc/systemd/system/tcg-medusa-backup.service
sudo install -m 0644 /opt/personifi-deployments/infra/systemd/tcg-medusa-backup.timer /etc/systemd/system/tcg-medusa-backup.timer
sudo systemctl daemon-reload
sudo systemctl enable --now tcg-medusa-backup.timer
systemctl list-timers tcg-medusa-backup.timer
```

Optional settings belong in `/etc/default/tcg-medusa-backup`:

```bash
RETENTION_DAYS=30
RCLONE_REMOTE=b2:bucket/tcg-medusa
POSTGRES_IMAGE=postgres:17-alpine
```

Check a run with:

```bash
sudo systemctl start tcg-medusa-backup.service
systemctl status tcg-medusa-backup.service --no-pager
journalctl -u tcg-medusa-backup.service --since today
```

## Verify A Backup

From `/opt/tcg-medusa/backups`, verify the paired files using their manifest:

```bash
cd /opt/tcg-medusa/backups
sha256sum -c manifests/tcg-medusa-TIMESTAMP.sha256
docker run --rm --volume "$PWD/postgres:/backup:ro" postgres:17-alpine pg_restore --list /backup/tcg-medusa-TIMESTAMP.dump >/dev/null
tar -tzf static/tcg-medusa-static-TIMESTAMP.tar.gz >/dev/null
```

Periodically copy a backup to an isolated test environment and perform a full restore. A backup is not proven until its restore succeeds.

## Restore

Use a maintenance window. Confirm the database dump and static archive have the same timestamp, verify the manifest, and retain the current data until application checks pass.

1. Stop the `tcg-medusa` Nomad job.
2. Move `/opt/tcg-medusa/static` to a timestamped pre-restore directory.
3. Extract the static archive into `/opt/tcg-medusa`.
4. Restore the custom-format database dump to the configured Medusa database.
5. Redeploy `tcg-medusa` and run the staging smoke test.
6. Remove the pre-restore directory only after product media, prices, cart, and admin checks pass.

Database restoration is destructive. Verify the target database URL before running `pg_restore --clean --if-exists`.
