#!/bin/bash
# ==========================================
# Personifi Quick Deployment Script
# Deploys Traefik, Backend, and Frontend jobs
# Assumes: Server setup is complete, and secrets are in .secrets.env
# ==========================================

# Configuration
DEPLOY_DIR="/opt/personifi-deployments"
NOMAD_JOBS_DIR="/opt/nomad/jobs"
SECRETS_FILE="$DEPLOY_DIR/.secrets.env"
GITOPS_USER="gitops"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "$1"
}

error() {
    log "${RED}❌ ERROR: $1${NC}"
    exit 1
}

warn() {
    log "${YELLOW}⚠️  WARNING: $1${NC}"
}

success() {
    log "${GREEN}✅ SUCCESS: $1${NC}"
}

# --- Check User and Context ---
if [ "$(whoami)" != "$GITOPS_USER" ]; then
    error "This script must be run as the $GITOPS_USER user (or via 'sudo -u $GITOPS_USER'). Current user is $(whoami)."
fi

cd $DEPLOY_DIR || error "Deployment directory $DEPLOY_DIR not found."

# --- Check Prerequisites ---
if [ ! -f "deployment.env" ]; then
    error "Missing deployment.env. Cannot get image tags."
fi

if [ ! -f "$SECRETS_FILE" ]; then
    error "Missing secrets file: $SECRETS_FILE. Please create this file first!"
fi

# --- Load Environment Variables ---
log "${YELLOW}1. Loading image tags from deployment.env...${NC}"
source deployment.env

log "${YELLOW}2. Loading secrets from $SECRETS_FILE...${NC}"
source $SECRETS_FILE

# --- Temporary Secret Files ---
TEMP_GHCR="/tmp/ghcr-creds.json"
TEMP_DB="/tmp/db-conn.json"
TEMP_AUTH0="/tmp/auth0-creds.json"
TEMP_POSTHOG="/tmp/posthog.json"

# --- 3. Update Nomad Secrets (Hides complex JSON logic) ---

# GHCR Secrets (DOCKER_USERNAME and DOCKER_PASSWORD must be in .secrets.env)
log "   -> Updating Nomad var personifi/ghcr..."
cat <<EOD > $TEMP_GHCR
{
  "Items": {
    "username": "$DOCKER_USERNAME",
    "password": "$DOCKER_PASSWORD"
  }
}
EOD
nomad var put personifi/ghcr @$TEMP_GHCR || error "Failed to put GHCR secret."

# Database Secrets (DB_CONNECTION_STRING must be in .secrets.env)
log "   -> Updating Nomad var personifi/database..."
cat <<EOD > $TEMP_DB
{
  "Items": {
    "connection_string": "$DB_CONNECTION_STRING"
  }
}
EOD
nomad var put personifi/database @$TEMP_DB || error "Failed to put database secret."

# Auth0 Secrets
log "   -> Updating Nomad var personifi/auth0-frontend..."
cat <<EOD > $TEMP_AUTH0
{
  "Items": {
    "auth0_client_secret": "$AUTH0_CLIENT_SECRET",
    "auth0_secret": "$AUTH0_SECRET"
  }
}
EOD
nomad var put personifi/auth0-frontend @$TEMP_AUTH0 || error "Failed to put database secret."

# Posthog Secrets
log "   -> Updating Nomad var personifi/posthog..."
cat <<EOD > $TEMP_POSTHOG
{
  "Items": {
    "poshog_key": "$POSTHOG_KEY",
  }
}
EOD
nomad var put personifi/posthog @$TEMP_POSTHOG || error "Failed to put posthog secret."

# --- 4. Deploy Jobs ---

# Traefik (Static Job - Deploy first)
log "${YELLOW}4. Deploying Traefik job...${NC}"
nomad job run infra/jobs/traefik.nomad.hcl || warn "Traefik deployment failed. Continuing..."

# Backend (Templated Job)
log "${YELLOW}5. Deploying Backend ($BACKEND_IMAGE)...${NC}"
sed "s|IMAGE_PLACEHOLDER|$BACKEND_IMAGE|g" \
    "infra/jobs/personifi-backend.nomad.template" > \
    "$NOMAD_JOBS_DIR/personifi-backend.nomad"
nomad job run "$NOMAD_JOBS_DIR/personifi-backend.nomad" || error "Backend deployment failed."

# Frontend (Templated Job)
log "${YELLOW}6. Deploying Frontend ($FRONTEND_IMAGE)...${NC}"
sed "s|IMAGE_PLACEHOLDER|$FRONTEND_IMAGE|g" \
    "infra/jobs/personifi-frontend.nomad.template" > \
    "$NOMAD_JOBS_DIR/personifi-frontend.nomad"
nomad job run "$NOMAD_JOBS_DIR/personifi-frontend.nomad" || error "Frontend deployment failed."

# --- Cleanup ---
rm -f $TEMP_GHCR $TEMP_DB
success "Deployment finished! Check status with 'nomad job status'."