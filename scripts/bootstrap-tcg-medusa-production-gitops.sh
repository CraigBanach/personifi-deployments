#!/bin/bash
set -euo pipefail
umask 077

DEPLOY_DIR="/opt/personifi-deployments"
GITOPS_USER="gitops"
INSTALLED_RECONCILER="/opt/gitops/gitops-deploy.sh"

if [ "$(whoami)" != "$GITOPS_USER" ]; then
    echo "ERROR: Run this as $GITOPS_USER" >&2
    exit 1
fi

cd "$DEPLOY_DIR"
test -f environments/tcg-medusa-production.env || {
    echo "ERROR: Production manifest is missing. Update the GitOps checkout first." >&2
    exit 1
}

install -D -m 700 scripts/gitops-deploy.sh "${INSTALLED_RECONCILER}.new"
mv "${INSTALLED_RECONCILER}.new" "$INSTALLED_RECONCILER"

echo "Installed the manifest-aware reconciler."
echo "Run scripts/quick-deploy-tcg-medusa.sh manually after confirming backups and the current production manifest."
