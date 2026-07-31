# TCG Medusa Media Backup Runbook

## Scope

Aiven manages PostgreSQL backups. This backup covers only uploaded Medusa files stored on the VPS at `/opt/tcg-medusa/static` and mounted into the backend container.

The VPS is a single point of failure for these files. Keep an off-site copy in a private Backblaze B2 bucket.

## Manual Backup

Run:

```bash
sudo -u gitops bash /opt/personifi-deployments/scripts/backup-tcg-medusa.sh
```

The script:

- Creates a compressed archive containing the complete `static` directory.
- Verifies the archive before publishing it.
- Writes a SHA-256 manifest.
- Keeps 14 days locally by default.
- Copies completed archives and manifests to `RCLONE_REMOTE` when configured.

Local backups are written beneath `/opt/tcg-medusa/backups`.

## Backblaze B2

Create a private B2 bucket and a bucket-scoped application key. Configure `rclone` as the `gitops` user, preferably with an `rclone crypt` remote over the B2 bucket.

Store optional settings in `/etc/default/tcg-medusa-backup`:

```bash
RETENTION_DAYS=30
RCLONE_REMOTE=tcg-backups-crypt:
```

The remote path receives `static` and `manifests` directories. Configure a B2 lifecycle rule to delete old remote objects after the desired retention period, such as 90 days.

Keep `/home/gitops/.config/rclone/rclone.conf` owned by `gitops` with mode `0600`. Do not commit B2 credentials or the rclone configuration.

## Enable Daily Backups

Run and inspect a manual backup before enabling the timer:

```bash
sudo install -m 0644 /opt/personifi-deployments/infra/systemd/tcg-medusa-backup.service /etc/systemd/system/tcg-medusa-backup.service
sudo install -m 0644 /opt/personifi-deployments/infra/systemd/tcg-medusa-backup.timer /etc/systemd/system/tcg-medusa-backup.timer
sudo systemctl daemon-reload
sudo systemctl enable --now tcg-medusa-backup.timer
systemctl list-timers tcg-medusa-backup.timer
```

Check a run with:

```bash
sudo systemctl start tcg-medusa-backup.service
systemctl status tcg-medusa-backup.service --no-pager
journalctl -u tcg-medusa-backup.service --since today
```

## Verify A Backup

From `/opt/tcg-medusa/backups`, verify an archive using its matching manifest:

```bash
cd /opt/tcg-medusa/backups
sha256sum -c manifests/tcg-medusa-static-TIMESTAMP.sha256
tar -tzf static/tcg-medusa-static-TIMESTAMP.tar.gz >/dev/null
```

Periodically download an archive from B2 and perform a test restore. A backup is not proven until its restore succeeds.

## Restore

Use a maintenance window and retain the current directory until application checks pass.

1. Stop the `tcg-medusa` Nomad job.
2. Move `/opt/tcg-medusa/static` to a timestamped pre-restore directory.
3. Extract the selected archive into `/opt/tcg-medusa`.
4. Redeploy `tcg-medusa` and run the staging smoke test.
5. Remove the pre-restore directory only after product media, storefront, and admin checks pass.
