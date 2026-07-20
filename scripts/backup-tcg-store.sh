#!/bin/bash
set -euo pipefail

BACKUP_ROOT="${BACKUP_ROOT:-/opt/tcg-store/backups}"
SECRETS_FILE="${SECRETS_FILE:-/opt/personifi-deployments/.tcg-store.secrets.env}"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
POSTGRES_DIR="$BACKUP_ROOT/postgres"
MEDIA_DIR="$BACKUP_ROOT/media"

if [ ! -f "$SECRETS_FILE" ]; then
    echo "Missing secrets file: $SECRETS_FILE" >&2
    exit 1
fi

source "$SECRETS_FILE"

: "${TCG_DATABASE_URL_DIRECT:?Set TCG_DATABASE_URL_DIRECT in $SECRETS_FILE for pg_dump}"

mkdir -p "$POSTGRES_DIR" "$MEDIA_DIR"

pg_dump "$TCG_DATABASE_URL_DIRECT" --format=custom --no-owner --no-acl --file "$POSTGRES_DIR/tcg-store-$TIMESTAMP.dump"
tar -czf "$MEDIA_DIR/tcg-store-media-$TIMESTAMP.tar.gz" -C /opt/tcg-store appsettings.json data-protection-keys images

find "$POSTGRES_DIR" -name 'tcg-store-*.dump' -mtime +7 -delete
find "$MEDIA_DIR" -name 'tcg-store-media-*.tar.gz' -mtime +7 -delete

echo "Backup complete: $TIMESTAMP"
