#!/bin/bash
set -euo pipefail

DEPLOY_DIR="/opt/personifi-deployments"
NOMAD_JOBS_DIR="/opt/nomad/jobs"
SECRETS_FILE="$DEPLOY_DIR/.tcg-medusa.secrets.env"
GITOPS_USER="gitops"

BACKEND_IMAGE="${BACKEND_IMAGE:-ghcr.io/craigbanach/tcg-store-backend:latest}"
STOREFRONT_IMAGE="${STOREFRONT_IMAGE:-ghcr.io/craigbanach/tcg-store-storefront:latest}"
DEPLOYMENT_ENVIRONMENT="${DEPLOYMENT_ENVIRONMENT:?Set DEPLOYMENT_ENVIRONMENT to staging or production}"
STOREFRONT_HOST="${STOREFRONT_HOST:?Set STOREFRONT_HOST}"
STOREFRONT_REDIRECT_HOST="${STOREFRONT_REDIRECT_HOST:?Set STOREFRONT_REDIRECT_HOST}"
API_HOST="${API_HOST:?Set API_HOST}"
RUN_CATALOG="${RUN_CATALOG:?Set RUN_CATALOG to true or false}"
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

validate_host() {
    case "$1" in
        ""|.*|*.|*[!a-zA-Z0-9.-]*) error "Invalid hostname: $1" ;;
    esac
}

case "$DEPLOYMENT_ENVIRONMENT" in
    staging|production) ;;
    *) error "DEPLOYMENT_ENVIRONMENT must be staging or production" ;;
esac

case "$RUN_CATALOG" in
    true|false) ;;
    *) error "RUN_CATALOG must be true or false" ;;
esac

validate_host "$STOREFRONT_HOST"
validate_host "$STOREFRONT_REDIRECT_HOST"
validate_host "$API_HOST"

if [ "$DEPLOYMENT_ENVIRONMENT" = "production" ] && [ "$RUN_CATALOG" != "false" ]; then
    error "Production deployments must set RUN_CATALOG=false"
fi

if [ "$(whoami)" != "$GITOPS_USER" ]; then
    error "Run this as $GITOPS_USER, for example: sudo -u $GITOPS_USER $0"
fi

cd "$DEPLOY_DIR" || error "Deployment directory not found: $DEPLOY_DIR"

if [ -f "$SECRETS_FILE" ]; then
    # shellcheck disable=SC1090
    source "$SECRETS_FILE"

    : "${DATABASE_URL:?Set DATABASE_URL in $SECRETS_FILE}"
    : "${JWT_SECRET:?Set JWT_SECRET in $SECRETS_FILE}"
    : "${COOKIE_SECRET:?Set COOKIE_SECRET in $SECRETS_FILE}"
    : "${NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY:?Set NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY in $SECRETS_FILE}"

    existing_stripe_api_key="$(nomad var get -item stripe_api_key tcg-store/medusa-secrets 2>/dev/null || true)"
    existing_stripe_webhook_secret="$(nomad var get -item stripe_webhook_secret tcg-store/medusa-secrets 2>/dev/null || true)"
    existing_stripe_publishable_key="$(nomad var get -item stripe_publishable_key tcg-store/medusa-secrets 2>/dev/null || true)"
    stripe_api_key="${STRIPE_API_KEY:-$existing_stripe_api_key}"
    stripe_webhook_secret="${STRIPE_WEBHOOK_SECRET:-$existing_stripe_webhook_secret}"
    stripe_publishable_key="${NEXT_PUBLIC_STRIPE_KEY:-$existing_stripe_publishable_key}"

    stripe_value_count=0
    for value in "$stripe_api_key" "$stripe_webhook_secret" "$stripe_publishable_key"; do
        if [ -n "$value" ]; then
            stripe_value_count=$((stripe_value_count + 1))
        fi
    done

    if [ "$stripe_value_count" -ne 0 ] && [ "$stripe_value_count" -ne 3 ]; then
        error "Set all Stripe values in $SECRETS_FILE or Nomad, or leave all three empty to use manual payment"
    fi

    if [ "$stripe_value_count" -eq 0 ]; then
        echo "Stripe is disabled; deploying with payment by arrangement"
    fi

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
    "stripe_publishable_key": "$stripe_publishable_key",
    "stripe_api_key": "$stripe_api_key",
    "stripe_webhook_secret": "$stripe_webhook_secret"
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

mkdir -p \
    "$NOMAD_JOBS_DIR" \
    /opt/tcg-medusa/redis \
    /opt/tcg-medusa/static \
    /opt/tcg-medusa/backups/static \
    /opt/tcg-medusa/backups/manifests

nomad job stop -purge tcg-medusa-redis >/dev/null 2>&1 || true

if [ "$DEPLOYMENT_ENVIRONMENT" = "production" ]; then
    redirect_filter=(-e "/PRODUCTION_REDIRECT_\(START\|END\)/d")
else
    redirect_filter=(-e "/PRODUCTION_REDIRECT_START/,/PRODUCTION_REDIRECT_END/d")
fi

sed \
    -e "s|BACKEND_IMAGE_PLACEHOLDER|$BACKEND_IMAGE|g" \
    -e "s|STOREFRONT_IMAGE_PLACEHOLDER|$STOREFRONT_IMAGE|g" \
    -e "s|DEPLOY_VERSION_PLACEHOLDER|$DEPLOY_VERSION|g" \
    -e "s|DEPLOYMENT_ENVIRONMENT_PLACEHOLDER|$DEPLOYMENT_ENVIRONMENT|g" \
    -e "s|STOREFRONT_HOST_PLACEHOLDER|$STOREFRONT_HOST|g" \
    -e "s|STOREFRONT_REDIRECT_HOST_PLACEHOLDER|$STOREFRONT_REDIRECT_HOST|g" \
    -e "s|API_HOST_PLACEHOLDER|$API_HOST|g" \
    "${redirect_filter[@]}" \
    "infra/jobs/tcg-medusa.nomad.template" > \
    "$NOMAD_JOBS_DIR/tcg-medusa.nomad"

nomad job run "$NOMAD_JOBS_DIR/tcg-medusa.nomad"

BACKEND_IMAGE="$BACKEND_IMAGE" \
API_HOST="$API_HOST" \
STOREFRONT_HOST="$STOREFRONT_HOST" \
    bash scripts/run-tcg-medusa-config.sh

if [ "$RUN_CATALOG" = "true" ]; then
    BACKEND_IMAGE="$BACKEND_IMAGE" \
    API_HOST="$API_HOST" \
    STOREFRONT_HOST="$STOREFRONT_HOST" \
    DEPLOYMENT_ENVIRONMENT="$DEPLOYMENT_ENVIRONMENT" \
        bash scripts/run-tcg-medusa-catalog.sh
else
    echo "Catalog synchronization skipped for $DEPLOYMENT_ENVIRONMENT"
fi

echo "TCG Medusa service, config, and catalog jobs submitted. Check status with: nomad job status tcg-medusa"
