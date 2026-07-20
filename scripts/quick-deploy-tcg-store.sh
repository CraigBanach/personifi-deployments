#!/bin/bash
set -euo pipefail

DEPLOY_DIR="/opt/personifi-deployments"
NOMAD_JOBS_DIR="/opt/nomad/jobs"
SECRETS_FILE="$DEPLOY_DIR/.tcg-store.secrets.env"
GITOPS_USER="gitops"
TCG_IMAGE="${TCG_IMAGE:-nopcommerceteam/nopcommerce:4.80.7}"

error() {
    echo "ERROR: $1" >&2
    exit 1
}

if [ "$(whoami)" != "$GITOPS_USER" ]; then
    error "Run this as $GITOPS_USER, for example: sudo -u $GITOPS_USER $0"
fi

cd "$DEPLOY_DIR" || error "Deployment directory not found: $DEPLOY_DIR"

if [ ! -f "$SECRETS_FILE" ]; then
    error "Missing secrets file: $SECRETS_FILE"
fi

source "$SECRETS_FILE"

: "${TCG_DATABASE_CONNECTION_STRING_DIRECT:?Set TCG_DATABASE_CONNECTION_STRING_DIRECT in $SECRETS_FILE}"
: "${TCG_DATABASE_CONNECTION_STRING_POOLED:?Set TCG_DATABASE_CONNECTION_STRING_POOLED in $SECRETS_FILE}"

mkdir -p /opt/tcg-store/data-protection-keys /opt/tcg-store/images /opt/tcg-store/backups/postgres /opt/tcg-store/backups/media
touch /opt/tcg-store/appsettings.json
mkdir -p "$NOMAD_JOBS_DIR"

TEMP_DB="/tmp/tcg-store-db-vars.json"
cat > "$TEMP_DB" <<EOD
{
  "Items": {
    "connection_string_direct": "$TCG_DATABASE_CONNECTION_STRING_DIRECT",
    "connection_string_pooled": "$TCG_DATABASE_CONNECTION_STRING_POOLED"
  }
}
EOD

nomad var put -force tcg-store/database @"$TEMP_DB"
rm -f "$TEMP_DB"

sed "s|IMAGE_PLACEHOLDER|$TCG_IMAGE|g" \
    "infra/jobs/tcg-store.nomad.template" > \
    "$NOMAD_JOBS_DIR/tcg-store.nomad"

nomad job run "$NOMAD_JOBS_DIR/tcg-store.nomad"

echo "TCG store deployment submitted. Check status with: nomad job status tcg-store"
