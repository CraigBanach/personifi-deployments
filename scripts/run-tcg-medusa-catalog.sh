#!/bin/bash
set -euo pipefail

DEPLOYMENT_ENVIRONMENT="${DEPLOYMENT_ENVIRONMENT:-${1:-production}}"
case "$DEPLOYMENT_ENVIRONMENT" in
    production) ;;
    *) echo "ERROR: This host only runs production jobs" >&2; exit 1 ;;
esac

echo "ERROR: Production catalog synchronization is disabled" >&2
exit 1
