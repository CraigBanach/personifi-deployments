#!/bin/bash
set -euo pipefail
umask 077

REQUESTED_ENVIRONMENT="${ENVIRONMENT:-production}"
case "$REQUESTED_ENVIRONMENT" in production) ;; *) echo "This host only backs up production" >&2; exit 1 ;; esac
ENVIRONMENT=production
BACKUP_ROOT="${BACKUP_ROOT:-/opt/tcg-medusa/production/backups}"
STATIC_ROOT="${STATIC_ROOT:-/opt/tcg-medusa/production/static}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
RCLONE_REMOTE="${RCLONE_REMOTE:-}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
STATIC_DIR="$BACKUP_ROOT/static"
MANIFEST_DIR="$BACKUP_ROOT/manifests"
STATIC_ARCHIVE="$STATIC_DIR/tcg-medusa-$ENVIRONMENT-static-$TIMESTAMP.tar.gz"
MANIFEST="$MANIFEST_DIR/tcg-medusa-$ENVIRONMENT-static-$TIMESTAMP.sha256"
TEMP_STATIC_ARCHIVE=""
TEMP_MANIFEST=""

cleanup() {
    [ -z "$TEMP_STATIC_ARCHIVE" ] || rm -f "$TEMP_STATIC_ARCHIVE"
    [ -z "$TEMP_MANIFEST" ] || rm -f "$TEMP_MANIFEST"
}

trap cleanup EXIT

for command in find sha256sum tar; do
    command -v "$command" >/dev/null || {
        echo "Missing required command: $command" >&2
        exit 1
    }
done

if [ ! -d "$STATIC_ROOT" ]; then
    echo "Missing Medusa static directory: $STATIC_ROOT" >&2
    exit 1
fi

mkdir -p "$STATIC_DIR" "$MANIFEST_DIR"
TEMP_STATIC_ARCHIVE="$(mktemp "$STATIC_DIR/.tcg-medusa-backup.XXXXXX")"
TEMP_MANIFEST="$(mktemp "$MANIFEST_DIR/.tcg-medusa-manifest.XXXXXX")"

tar -czf "$TEMP_STATIC_ARCHIVE" \
    -C "$(dirname "$STATIC_ROOT")" \
    "$(basename "$STATIC_ROOT")"
tar -tzf "$TEMP_STATIC_ARCHIVE" >/dev/null

mv "$TEMP_STATIC_ARCHIVE" "$STATIC_ARCHIVE"
chmod 600 "$STATIC_ARCHIVE"

(
    cd "$BACKUP_ROOT"
    sha256sum "static/$(basename "$STATIC_ARCHIVE")"
) > "$TEMP_MANIFEST"
mv "$TEMP_MANIFEST" "$MANIFEST"
chmod 600 "$MANIFEST"

if [ -n "$RCLONE_REMOTE" ]; then
    command -v rclone >/dev/null || {
        echo "RCLONE_REMOTE is set but rclone is unavailable" >&2
        exit 1
    }

    rclone copy "$STATIC_ARCHIVE" "$RCLONE_REMOTE/static"
    rclone copy "$MANIFEST" "$RCLONE_REMOTE/manifests"
fi

find "$STATIC_DIR" -type f -name "tcg-medusa-$ENVIRONMENT-static-*.tar.gz" -mtime "+$RETENTION_DAYS" -delete
find "$MANIFEST_DIR" -type f -name "tcg-medusa-$ENVIRONMENT-static-*.sha256" -mtime "+$RETENTION_DAYS" -delete

echo "Backup complete: $TIMESTAMP"
echo "Static media: $STATIC_ARCHIVE"
echo "Manifest: $MANIFEST"
