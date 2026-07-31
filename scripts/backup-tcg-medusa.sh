#!/bin/bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/opt/tcg-medusa/backups}"
STATIC_ROOT="${STATIC_ROOT:-/opt/tcg-medusa/static}"
DATABASE_VAR_PATH="${DATABASE_VAR_PATH:-tcg-store/medusa-database}"
RETENTION_DAYS="${RETENTION_DAYS:-14}"
RCLONE_REMOTE="${RCLONE_REMOTE:-}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
POSTGRES_DIR="$BACKUP_ROOT/postgres"
STATIC_DIR="$BACKUP_ROOT/static"
MANIFEST_DIR="$BACKUP_ROOT/manifests"
DATABASE_ARCHIVE="$POSTGRES_DIR/tcg-medusa-$TIMESTAMP.dump"
STATIC_ARCHIVE="$STATIC_DIR/tcg-medusa-static-$TIMESTAMP.tar.gz"
MANIFEST="$MANIFEST_DIR/tcg-medusa-$TIMESTAMP.sha256"
TEMP_DATABASE_ARCHIVE="$DATABASE_ARCHIVE.tmp"
TEMP_STATIC_ARCHIVE="$STATIC_ARCHIVE.tmp"
TEMP_MANIFEST="$MANIFEST.tmp"

cleanup() {
    rm -f "$TEMP_DATABASE_ARCHIVE" "$TEMP_STATIC_ARCHIVE" "$TEMP_MANIFEST"
}

trap cleanup EXIT

for command in find nomad pg_dump pg_restore sha256sum tar; do
    command -v "$command" >/dev/null || {
        echo "Missing required command: $command" >&2
        exit 1
    }
done

if [ ! -d "$STATIC_ROOT" ]; then
    echo "Missing Medusa static directory: $STATIC_ROOT" >&2
    exit 1
fi

DATABASE_URL="${DATABASE_URL:-$(nomad var get -item database_url "$DATABASE_VAR_PATH")}"
: "${DATABASE_URL:?Could not resolve DATABASE_URL from Nomad variable $DATABASE_VAR_PATH}"

mkdir -p "$POSTGRES_DIR" "$STATIC_DIR" "$MANIFEST_DIR"

pg_dump "$DATABASE_URL" \
    --format=custom \
    --no-owner \
    --no-acl \
    --file "$TEMP_DATABASE_ARCHIVE"
pg_restore --list "$TEMP_DATABASE_ARCHIVE" >/dev/null

tar -czf "$TEMP_STATIC_ARCHIVE" \
    -C "$(dirname "$STATIC_ROOT")" \
    "$(basename "$STATIC_ROOT")"
tar -tzf "$TEMP_STATIC_ARCHIVE" >/dev/null

mv "$TEMP_DATABASE_ARCHIVE" "$DATABASE_ARCHIVE"
mv "$TEMP_STATIC_ARCHIVE" "$STATIC_ARCHIVE"
chmod 600 "$DATABASE_ARCHIVE" "$STATIC_ARCHIVE"

(
    cd "$BACKUP_ROOT"
    sha256sum \
        "postgres/$(basename "$DATABASE_ARCHIVE")" \
        "static/$(basename "$STATIC_ARCHIVE")"
) > "$TEMP_MANIFEST"
mv "$TEMP_MANIFEST" "$MANIFEST"
chmod 600 "$MANIFEST"

if [ -n "$RCLONE_REMOTE" ]; then
    command -v rclone >/dev/null || {
        echo "RCLONE_REMOTE is set but rclone is unavailable" >&2
        exit 1
    }

    rclone copy "$DATABASE_ARCHIVE" "$RCLONE_REMOTE/postgres"
    rclone copy "$STATIC_ARCHIVE" "$RCLONE_REMOTE/static"
    rclone copy "$MANIFEST" "$RCLONE_REMOTE/manifests"
fi

find "$POSTGRES_DIR" -type f -name 'tcg-medusa-*.dump' -mtime "+$RETENTION_DAYS" -delete
find "$STATIC_DIR" -type f -name 'tcg-medusa-static-*.tar.gz' -mtime "+$RETENTION_DAYS" -delete
find "$MANIFEST_DIR" -type f -name 'tcg-medusa-*.sha256' -mtime "+$RETENTION_DAYS" -delete

echo "Backup complete: $TIMESTAMP"
echo "Database: $DATABASE_ARCHIVE"
echo "Static media: $STATIC_ARCHIVE"
echo "Manifest: $MANIFEST"
