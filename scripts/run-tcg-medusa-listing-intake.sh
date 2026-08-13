#!/bin/bash
set -euo pipefail

DEPLOY_DIR="/opt/personifi-deployments"
NOMAD_JOBS_DIR="/opt/nomad/jobs"
GITOPS_USER="gitops"

if [ "$(whoami)" != "$GITOPS_USER" ]; then
    echo "ERROR: Run this as $GITOPS_USER, for example: sudo -u $GITOPS_USER bash $0" >&2
    exit 1
fi

cd "$DEPLOY_DIR"

if [ -z "${BACKEND_IMAGE:-}" ]; then
    if [ -f deployment.env ]; then
        # shellcheck disable=SC1091
        source deployment.env
        BACKEND_IMAGE="${TCG_MEDUSA_BACKEND_IMAGE:-}"
    fi
fi

API_HOST="${API_HOST:-${TCG_MEDUSA_API_HOST:-}}"
STOREFRONT_HOST="${STOREFRONT_HOST:-${TCG_MEDUSA_STOREFRONT_HOST:-}}"
DEPLOYMENT_ENVIRONMENT="${DEPLOYMENT_ENVIRONMENT:-${TCG_MEDUSA_ENVIRONMENT:-}}"

: "${API_HOST:?Set API_HOST}"
: "${STOREFRONT_HOST:?Set STOREFRONT_HOST}"
: "${DEPLOYMENT_ENVIRONMENT:?Set DEPLOYMENT_ENVIRONMENT}"

if [ "$DEPLOYMENT_ENVIRONMENT" = "production" ] && [ "${ALLOW_PRODUCTION_CATALOG_SYNC:-false}" != "true" ]; then
    echo "ERROR: Production catalog synchronization requires ALLOW_PRODUCTION_CATALOG_SYNC=true" >&2
    exit 1
fi

if [ -z "${BACKEND_IMAGE:-}" ]; then
    echo "ERROR: BACKEND_IMAGE or TCG_MEDUSA_BACKEND_IMAGE is required" >&2
    exit 1
fi

nomad var get tcg-store/medusa-database >/dev/null
nomad var get tcg-store/medusa-secrets >/dev/null

mkdir -p "$NOMAD_JOBS_DIR"

sed \
    -e "s|BACKEND_IMAGE_PLACEHOLDER|$BACKEND_IMAGE|g" \
    -e "s|API_HOST_PLACEHOLDER|$API_HOST|g" \
    -e "s|STOREFRONT_HOST_PLACEHOLDER|$STOREFRONT_HOST|g" \
    "infra/jobs/tcg-medusa-listing-intake.nomad.template" > \
    "$NOMAD_JOBS_DIR/tcg-medusa-listing-intake.nomad"

# Nomad does not rerun an unchanged terminal batch job. Purge any completed
# intake job so this submission always creates a fresh allocation.
nomad job stop -purge tcg-medusa-listing-intake >/dev/null 2>&1 || true
nomad job run "$NOMAD_JOBS_DIR/tcg-medusa-listing-intake.nomad"

echo "TCG Medusa listing-intake batch job submitted. Check status with: nomad job status tcg-medusa-listing-intake"
