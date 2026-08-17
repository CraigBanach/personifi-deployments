#!/bin/bash
set -euo pipefail
umask 077

DEPLOY_DIR="/opt/personifi-deployments"
NOMAD_JOBS_DIR="/opt/nomad/jobs"
GITOPS_USER="gitops"
DEPLOYMENT_ENVIRONMENT="${DEPLOYMENT_ENVIRONMENT:-${1:-production}}"

if [ "$(whoami)" != "$GITOPS_USER" ]; then
    echo "ERROR: Run this as $GITOPS_USER, for example: sudo -u $GITOPS_USER $0" >&2
    exit 1
fi

case "$DEPLOYMENT_ENVIRONMENT" in production) ;; *) echo "ERROR: This host only runs production jobs" >&2; exit 1 ;; esac
cd "$DEPLOY_DIR"

if [ -z "${BACKEND_IMAGE:-}" ]; then
    # shellcheck disable=SC1090
    source "environments/tcg-medusa-$DEPLOYMENT_ENVIRONMENT.env"
    BACKEND_IMAGE="${TCG_MEDUSA_BACKEND_IMAGE:?Set TCG_MEDUSA_BACKEND_IMAGE}"
fi

: "${API_HOST:=${TCG_MEDUSA_API_HOST:-}}"
: "${STOREFRONT_HOST:=${TCG_MEDUSA_STOREFRONT_HOST:-}}"
: "${API_HOST:?Set API_HOST}"
: "${STOREFRONT_HOST:?Set STOREFRONT_HOST}"

case "$DEPLOYMENT_ENVIRONMENT:$STOREFRONT_HOST:$API_HOST" in
    production:freesplash.co.uk:api.freesplash.co.uk) ;;
    *) echo "ERROR: Hostnames do not match the approved $DEPLOYMENT_ENVIRONMENT bindings" >&2; exit 1 ;;
esac
case "$BACKEND_IMAGE" in *:latest*) echo "ERROR: Mutable latest images are not allowed" >&2; exit 1 ;; esac
[[ "$BACKEND_IMAGE" =~ @sha256:[0-9a-f]{64}$ ]] || { echo "ERROR: Production images must be digest-pinned" >&2; exit 1; }

VAR_PATH="tcg-store/medusa/$DEPLOYMENT_ENVIRONMENT"
JOB_NAME="tcg-medusa-$DEPLOYMENT_ENVIRONMENT-config"
JOB_FILE="$NOMAD_JOBS_DIR/$JOB_NAME.nomad"
nomad var get "$VAR_PATH/database" >/dev/null
nomad var get "$VAR_PATH/secrets" >/dev/null
mkdir -p "$NOMAD_JOBS_DIR"

sed \
    -e "s|BACKEND_IMAGE_PLACEHOLDER|$BACKEND_IMAGE|g" \
    -e "s|API_HOST_PLACEHOLDER|$API_HOST|g" \
    -e "s|STOREFRONT_HOST_PLACEHOLDER|$STOREFRONT_HOST|g" \
    -e "s|DEPLOYMENT_ENVIRONMENT_PLACEHOLDER|$DEPLOYMENT_ENVIRONMENT|g" \
    -e "s|TCG_MEDUSA_VAR_PATH_PLACEHOLDER|$VAR_PATH|g" \
    "infra/jobs/tcg-medusa-config.nomad.template" > "$JOB_FILE"

nomad job stop -purge "$JOB_NAME" >/dev/null 2>&1 || true
nomad job run "$JOB_FILE"
bash scripts/wait-for-nomad-batch.sh "$JOB_NAME"
echo "TCG Medusa $DEPLOYMENT_ENVIRONMENT config completed successfully"
