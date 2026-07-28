#!/bin/bash
set -euo pipefail

DEPLOY_DIR="/opt/personifi-deployments"
NOMAD_JOBS_DIR="/opt/nomad/jobs"
SECRETS_FILE="$DEPLOY_DIR/.tcg-medusa.secrets.env"
GITOPS_USER="gitops"

BACKEND_IMAGE="${BACKEND_IMAGE:-ghcr.io/craigbanach/tcg-store-backend:latest}"
STOREFRONT_IMAGE="${STOREFRONT_IMAGE:-ghcr.io/craigbanach/tcg-store-storefront:latest}"
DEPLOY_VERSION="$(date -u +%Y%m%d%H%M%S)"
TEMP_DB="/tmp/tcg-medusa-database-vars.json"
TEMP_SECRETS="/tmp/tcg-medusa-secret-vars.json"

cleanup() {
    rm -f "$TEMP_DB" "$TEMP_SECRETS"
}

trap cleanup EXIT

error() {
    echo "ERROR: $1" >&2
    exit 1
}

if [ "$(whoami)" != "$GITOPS_USER" ]; then
    error "Run this as $GITOPS_USER, for example: sudo -u $GITOPS_USER $0"
fi

cd "$DEPLOY_DIR" || error "Deployment directory not found: $DEPLOY_DIR"

if [ -f "$SECRETS_FILE" ]; then
    source "$SECRETS_FILE"

    : "${DATABASE_URL:?Set DATABASE_URL in $SECRETS_FILE}"
    : "${JWT_SECRET:?Set JWT_SECRET in $SECRETS_FILE}"
    : "${COOKIE_SECRET:?Set COOKIE_SECRET in $SECRETS_FILE}"
    : "${NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY:?Set NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY in $SECRETS_FILE}"

    cat > "$TEMP_DB" <<EOD
{
  "Items": {
    "database_url": "$DATABASE_URL"
  }
}
EOD

    cat > "$TEMP_SECRETS" <<EOD
{
  "Items": {
    "jwt_secret": "$JWT_SECRET",
    "cookie_secret": "$COOKIE_SECRET",
    "publishable_key": "$NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY",
    "stripe_publishable_key": "${NEXT_PUBLIC_STRIPE_KEY:-}"
  }
}
EOD

    nomad var put -force tcg-store/medusa-database @"$TEMP_DB"
    nomad var put -force tcg-store/medusa-secrets @"$TEMP_SECRETS"
else
    nomad var get tcg-store/medusa-database >/dev/null || \
        error "Missing $SECRETS_FILE and Nomad variable tcg-store/medusa-database"
    nomad var get tcg-store/medusa-secrets >/dev/null || \
        error "Missing $SECRETS_FILE and Nomad variable tcg-store/medusa-secrets"
fi

mkdir -p "$NOMAD_JOBS_DIR" /opt/tcg-medusa/redis

cp "infra/jobs/tcg-medusa-redis.nomad.hcl" "$NOMAD_JOBS_DIR/tcg-medusa-redis.nomad"
nomad job run "$NOMAD_JOBS_DIR/tcg-medusa-redis.nomad"

sed \
    -e "s|BACKEND_IMAGE_PLACEHOLDER|$BACKEND_IMAGE|g" \
    -e "s|STOREFRONT_IMAGE_PLACEHOLDER|$STOREFRONT_IMAGE|g" \
    -e "s|DEPLOY_VERSION_PLACEHOLDER|$DEPLOY_VERSION|g" \
    "infra/jobs/tcg-medusa.nomad.template" > \
    "$NOMAD_JOBS_DIR/tcg-medusa.nomad"

nomad job run "$NOMAD_JOBS_DIR/tcg-medusa.nomad"

echo "TCG Medusa deployment submitted. Check status with: nomad job status tcg-medusa"
