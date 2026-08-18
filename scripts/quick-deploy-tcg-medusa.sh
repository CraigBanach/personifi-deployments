#!/bin/bash
set -euo pipefail
umask 077

DEPLOY_DIR="/opt/personifi-deployments"
NOMAD_JOBS_DIR="/opt/nomad/jobs"
GITOPS_USER="gitops"

requested_backend_image="${BACKEND_IMAGE:-}"
requested_storefront_image="${STOREFRONT_IMAGE:-}"

REQUESTED_ENVIRONMENT="${DEPLOYMENT_ENVIRONMENT:-${1:-production}}"
case "$REQUESTED_ENVIRONMENT" in
    production) ;;
    *) echo "ERROR: This host only deploys the production environment" >&2; exit 1 ;;
esac

MANIFEST_FILE="$DEPLOY_DIR/environments/tcg-medusa-production.env"
if [ ! -f "$MANIFEST_FILE" ]; then
    echo "ERROR: Deployment manifest not found: $MANIFEST_FILE" >&2
    exit 1
fi
# shellcheck disable=SC1091
source "$MANIFEST_FILE"

if [ "${TCG_MEDUSA_ENVIRONMENT:-}" != "$REQUESTED_ENVIRONMENT" ]; then
    echo "ERROR: Manifest environment does not match requested environment $REQUESTED_ENVIRONMENT" >&2
    exit 1
fi

BACKEND_IMAGE="${requested_backend_image:-${TCG_MEDUSA_BACKEND_IMAGE:?Set TCG_MEDUSA_BACKEND_IMAGE}}"
STOREFRONT_IMAGE="${requested_storefront_image:-${TCG_MEDUSA_STOREFRONT_IMAGE:?Set TCG_MEDUSA_STOREFRONT_IMAGE}}"
DEPLOYMENT_ENVIRONMENT="${TCG_MEDUSA_ENVIRONMENT:?Set TCG_MEDUSA_ENVIRONMENT}"
STOREFRONT_HOST="${STOREFRONT_HOST:-${TCG_MEDUSA_STOREFRONT_HOST:?Set TCG_MEDUSA_STOREFRONT_HOST}}"
STOREFRONT_REDIRECT_HOST="${STOREFRONT_REDIRECT_HOST:-${TCG_MEDUSA_STOREFRONT_REDIRECT_HOST:?Set TCG_MEDUSA_STOREFRONT_REDIRECT_HOST}}"
API_HOST="${API_HOST:-${TCG_MEDUSA_API_HOST:?Set TCG_MEDUSA_API_HOST}}"
RUN_CONFIG="${RUN_CONFIG:-${TCG_MEDUSA_RUN_CONFIG:?Set TCG_MEDUSA_RUN_CONFIG}}"
RUN_CATALOG="${RUN_CATALOG:-${TCG_MEDUSA_RUN_CATALOG:?Set TCG_MEDUSA_RUN_CATALOG}}"
DEPLOY_VERSION="$(date -u +%Y%m%d%H%M%S)"
SECRETS_FILE="$DEPLOY_DIR/.tcg-medusa-$DEPLOYMENT_ENVIRONMENT.secrets.env"
VAR_PATH="tcg-store/medusa/$DEPLOYMENT_ENVIRONMENT"
STATE_PATH="/opt/tcg-medusa/$DEPLOYMENT_ENVIRONMENT"
SERVICE_JOB="tcg-medusa-$DEPLOYMENT_ENVIRONMENT"
TEMP_DB="$(mktemp --suffix=.json)"
TEMP_SECRETS="$(mktemp --suffix=.json)"

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

case "$RUN_CONFIG:$RUN_CATALOG" in
    true:true|true:false|false:true|false:false) ;;
    *) error "RUN_CONFIG and RUN_CATALOG must be true or false" ;;
esac

case "$BACKEND_IMAGE:$STOREFRONT_IMAGE" in
    *:latest*|*":latest"*) error "Mutable latest image references are not allowed" ;;
esac

case "$DEPLOYMENT_ENVIRONMENT:$STOREFRONT_HOST:$STOREFRONT_REDIRECT_HOST:$API_HOST" in
    production:freesplash.co.uk:www.freesplash.co.uk:api.freesplash.co.uk) ;;
    *) error "Hostnames do not match the approved $DEPLOYMENT_ENVIRONMENT bindings" ;;
esac

validate_host "$STOREFRONT_HOST"
validate_host "$STOREFRONT_REDIRECT_HOST"
validate_host "$API_HOST"

if [ "$RUN_CATALOG" != "false" ]; then
    error "Production deployments must set RUN_CATALOG=false"
fi

if [[ ! "$BACKEND_IMAGE" =~ @sha256:[0-9a-f]{64}$ ]] || \
    [[ ! "$STOREFRONT_IMAGE" =~ @sha256:[0-9a-f]{64}$ ]]; then
    error "Production backend and storefront images must be digest-pinned"
fi

if [ "$(whoami)" != "$GITOPS_USER" ]; then
    error "Run this as $GITOPS_USER, for example: sudo -u $GITOPS_USER $0"
fi

cd "$DEPLOY_DIR" || error "Deployment directory not found: $DEPLOY_DIR"

# Preserve the existing production secret file during the one-time split.
if [ ! -f "$SECRETS_FILE" ] && [ -f "$DEPLOY_DIR/.tcg-medusa.secrets.env" ]; then
    mv "$DEPLOY_DIR/.tcg-medusa.secrets.env" "$SECRETS_FILE"
    chmod 600 "$SECRETS_FILE"
fi

# Migrate servers installed with a copied reconciler to the current repository version.
installed_gitops_script="/opt/gitops/gitops-deploy.sh"
if [ -w "$(dirname "$installed_gitops_script")" ] && \
    ! cmp -s scripts/gitops-deploy.sh "$installed_gitops_script"; then
    install -m 700 scripts/gitops-deploy.sh "${installed_gitops_script}.new"
    mv "${installed_gitops_script}.new" "$installed_gitops_script"
fi

if [ -f "$SECRETS_FILE" ]; then
    # shellcheck disable=SC1090
    source "$SECRETS_FILE"

    : "${DATABASE_URL:?Set DATABASE_URL in $SECRETS_FILE}"
    : "${JWT_SECRET:?Set JWT_SECRET in $SECRETS_FILE}"
    : "${COOKIE_SECRET:?Set COOKIE_SECRET in $SECRETS_FILE}"
    : "${NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY:?Set NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY in $SECRETS_FILE}"

    existing_stripe_api_key="$(nomad var get -item stripe_api_key "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_stripe_webhook_secret="$(nomad var get -item stripe_webhook_secret "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_stripe_publishable_key="$(nomad var get -item stripe_publishable_key "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_contact_smtp_host="$(nomad var get -item contact_smtp_host "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_contact_smtp_port="$(nomad var get -item contact_smtp_port "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_contact_smtp_secure="$(nomad var get -item contact_smtp_secure "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_contact_smtp_user="$(nomad var get -item contact_smtp_user "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_contact_smtp_password="$(nomad var get -item contact_smtp_password "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_contact_from_email="$(nomad var get -item contact_from_email "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_contact_to_email="$(nomad var get -item contact_to_email "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_transactional_smtp_host="$(nomad var get -item transactional_smtp_host "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_transactional_smtp_port="$(nomad var get -item transactional_smtp_port "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_transactional_smtp_secure="$(nomad var get -item transactional_smtp_secure "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_transactional_smtp_user="$(nomad var get -item transactional_smtp_user "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_transactional_smtp_password="$(nomad var get -item transactional_smtp_password "$VAR_PATH/secrets" 2>/dev/null || true)"
    existing_transactional_from_email="$(nomad var get -item transactional_from_email "$VAR_PATH/secrets" 2>/dev/null || true)"
    stripe_api_key="${STRIPE_API_KEY:-$existing_stripe_api_key}"
    stripe_webhook_secret="${STRIPE_WEBHOOK_SECRET:-$existing_stripe_webhook_secret}"
    stripe_publishable_key="${NEXT_PUBLIC_STRIPE_KEY:-$existing_stripe_publishable_key}"
    contact_smtp_host="${CONTACT_SMTP_HOST:-$existing_contact_smtp_host}"
    contact_smtp_user="${CONTACT_SMTP_USER:-$existing_contact_smtp_user}"
    contact_smtp_password="${CONTACT_SMTP_PASSWORD:-$existing_contact_smtp_password}"
    contact_from_email="${CONTACT_FROM_EMAIL:-$existing_contact_from_email}"
    contact_to_email="${CONTACT_TO_EMAIL:-$existing_contact_to_email}"
    transactional_smtp_host="${TRANSACTIONAL_SMTP_HOST:-$existing_transactional_smtp_host}"
    transactional_smtp_user="${TRANSACTIONAL_SMTP_USER:-$existing_transactional_smtp_user}"
    transactional_smtp_password="${TRANSACTIONAL_SMTP_PASSWORD:-$existing_transactional_smtp_password}"
    transactional_from_email="${TRANSACTIONAL_FROM_EMAIL:-$existing_transactional_from_email}"

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

    contact_value_count=0
    for value in "$contact_smtp_host" "$contact_smtp_user" "$contact_smtp_password" "$contact_from_email" "$contact_to_email"; do
        if [ -n "$value" ]; then
            contact_value_count=$((contact_value_count + 1))
        fi
    done

    if [ "$contact_value_count" -ne 0 ] && [ "$contact_value_count" -ne 5 ]; then
        error "Set all contact SMTP values in $SECRETS_FILE or Nomad, or leave all five empty"
    fi

    if [ "$contact_value_count" -eq 5 ]; then
        contact_smtp_port="${CONTACT_SMTP_PORT:-${existing_contact_smtp_port:-465}}"
        contact_smtp_secure="${CONTACT_SMTP_SECURE:-${existing_contact_smtp_secure:-true}}"
    else
        contact_smtp_port=""
        contact_smtp_secure=""
        echo "Contact email delivery is disabled until SMTP values are configured"
    fi

    transactional_value_count=0
    for value in "$transactional_smtp_host" "$transactional_smtp_user" "$transactional_smtp_password" "$transactional_from_email"; do
        if [ -n "$value" ]; then
            transactional_value_count=$((transactional_value_count + 1))
        fi
    done

    if [ "$transactional_value_count" -ne 0 ] && [ "$transactional_value_count" -ne 4 ]; then
        error "Set all transactional SMTP values in $SECRETS_FILE or Nomad, or leave all four empty"
    fi

    if [ "$transactional_value_count" -eq 4 ]; then
        transactional_smtp_port="${TRANSACTIONAL_SMTP_PORT:-${existing_transactional_smtp_port:-587}}"
        transactional_smtp_secure="${TRANSACTIONAL_SMTP_SECURE:-${existing_transactional_smtp_secure:-false}}"
    else
        transactional_smtp_port=""
        transactional_smtp_secure=""
        echo "Transactional email delivery is disabled until SMTP values are configured"
    fi

    export DATABASE_URL JWT_SECRET COOKIE_SECRET NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY
    export stripe_publishable_key stripe_api_key stripe_webhook_secret
    export contact_smtp_host contact_smtp_port contact_smtp_secure
    export contact_smtp_user contact_smtp_password contact_from_email contact_to_email
    export transactional_smtp_host transactional_smtp_port transactional_smtp_secure
    export transactional_smtp_user transactional_smtp_password transactional_from_email

    python3 - "$TEMP_DB" "$TEMP_SECRETS" <<'PY'
import json
import os
import sys

database_path, secrets_path = sys.argv[1:]

with open(database_path, "w", encoding="utf-8") as database_file:
    json.dump({"Items": {"database_url": os.environ["DATABASE_URL"]}}, database_file)

secret_names = (
    "jwt_secret",
    "cookie_secret",
    "publishable_key",
    "stripe_publishable_key",
    "stripe_api_key",
    "stripe_webhook_secret",
    "contact_smtp_host",
    "contact_smtp_port",
    "contact_smtp_secure",
    "contact_smtp_user",
    "contact_smtp_password",
    "contact_from_email",
    "contact_to_email",
    "transactional_smtp_host",
    "transactional_smtp_port",
    "transactional_smtp_secure",
    "transactional_smtp_user",
    "transactional_smtp_password",
    "transactional_from_email",
)
environment_names = {
    "publishable_key": "NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY",
    "jwt_secret": "JWT_SECRET",
    "cookie_secret": "COOKIE_SECRET",
}

with open(secrets_path, "w", encoding="utf-8") as secrets_file:
    json.dump(
        {
            "Items": {
                name: os.environ[environment_names.get(name, name)]
                for name in secret_names
            }
        },
        secrets_file,
    )
PY

    nomad var put -force "$VAR_PATH/database" "@$TEMP_DB"
    nomad var put -force "$VAR_PATH/secrets" "@$TEMP_SECRETS"
else
    nomad var get "$VAR_PATH/database" >/dev/null || \
        error "Missing $SECRETS_FILE and Nomad variable $VAR_PATH/database"
    nomad var get "$VAR_PATH/secrets" >/dev/null || \
        error "Missing $SECRETS_FILE and Nomad variable $VAR_PATH/secrets"
fi

for directory in redis static backups; do
    if [ -d "/opt/tcg-medusa/$directory" ] && [ ! -e "$STATE_PATH/$directory" ]; then
        error "Move /opt/tcg-medusa/$directory to $STATE_PATH as root before deploying"
    fi
done

# Legacy jobs are retired only after state is confirmed in its qualified path.
nomad job stop -purge tcg-medusa >/dev/null 2>&1 || true
nomad job stop -purge tcg-medusa-redis >/dev/null 2>&1 || true

mkdir -p \
    "$NOMAD_JOBS_DIR" \
    "$STATE_PATH/redis" \
    "$STATE_PATH/static" \
    "$STATE_PATH/catalog-intake" \
    "$STATE_PATH/backups/static" \
    "$STATE_PATH/backups/manifests"

sed \
    -e "s|BACKEND_IMAGE_PLACEHOLDER|$BACKEND_IMAGE|g" \
    -e "s|STOREFRONT_IMAGE_PLACEHOLDER|$STOREFRONT_IMAGE|g" \
    -e "s|DEPLOY_VERSION_PLACEHOLDER|$DEPLOY_VERSION|g" \
    -e "s|DEPLOYMENT_ENVIRONMENT_PLACEHOLDER|$DEPLOYMENT_ENVIRONMENT|g" \
    -e "s|PRODUCTION_DATA_MUTATION_PLACEHOLDER|${TCG_MEDUSA_ALLOW_PRODUCTION_DATA_MUTATION:-false}|g" \
    -e "s|TCG_MEDUSA_VAR_PATH_PLACEHOLDER|$VAR_PATH|g" \
    -e "s|TCG_MEDUSA_STATE_PATH_PLACEHOLDER|$STATE_PATH|g" \
    -e "s|STOREFRONT_HOST_PLACEHOLDER|$STOREFRONT_HOST|g" \
    -e "s|STOREFRONT_REDIRECT_HOST_PLACEHOLDER|$STOREFRONT_REDIRECT_HOST|g" \
    -e "s|API_HOST_PLACEHOLDER|$API_HOST|g" \
    -e "/PRODUCTION_REDIRECT_\(START\|END\)/d" \
    "infra/jobs/tcg-medusa.nomad.template" > \
    "$NOMAD_JOBS_DIR/$SERVICE_JOB.nomad"

nomad job run "$NOMAD_JOBS_DIR/$SERVICE_JOB.nomad"

if [ "$RUN_CONFIG" = "true" ]; then
    BACKEND_IMAGE="$BACKEND_IMAGE" API_HOST="$API_HOST" STOREFRONT_HOST="$STOREFRONT_HOST" \
        DEPLOYMENT_ENVIRONMENT="$DEPLOYMENT_ENVIRONMENT" bash scripts/run-tcg-medusa-config.sh
else
    echo "Store configuration skipped for $DEPLOYMENT_ENVIRONMENT"
fi

echo "Catalog synchronization disabled for production"

echo "TCG Medusa $DEPLOYMENT_ENVIRONMENT deployment complete. Check status with: nomad job status $SERVICE_JOB"
