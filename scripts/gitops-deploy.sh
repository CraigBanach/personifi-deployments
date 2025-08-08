#!/bin/bash
# GitOps Deployment Script for Personifi
# This script polls the deployment repository and deploys changes

DEPLOY_REPO="/opt/personifi-deployments"
LOG_FILE="/var/log/gitops-deploy.log"
NOMAD_JOBS_DIR="/opt/nomad-jobs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

error() {
    log "${RED}❌ $1${NC}"
}

success() {
    log "${GREEN}✅ $1${NC}"
}

info() {
    log "${BLUE}ℹ️  $1${NC}"
}

warn() {
    log "${YELLOW}⚠️  $1${NC}"
}

# Ensure log directory exists
mkdir -p $(dirname $LOG_FILE)

# Clone repo if it doesn't exist
if [ ! -d "$DEPLOY_REPO" ]; then
    info "Cloning deployment repository..."
    git clone https://github.com/craigbanach/personifi-deployments.git $DEPLOY_REPO
    if [ $? -ne 0 ]; then
        error "Failed to clone deployment repository"
        exit 1
    fi
fi

cd $DEPLOY_REPO

# Fetch latest changes
git fetch origin main 2>/dev/null
if [ $? -ne 0 ]; then
    warn "Failed to fetch from origin, continuing with local state"
fi

# Check if there are new changes
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main 2>/dev/null || echo $LOCAL_COMMIT)

if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
    info "🔄 New deployment detected"
    
    # Get the commit details
    OLD_COMMIT=$(git rev-parse --short HEAD)
    git pull origin main
    NEW_COMMIT=$(git rev-parse --short HEAD)
    
    info "Updating from $OLD_COMMIT to $NEW_COMMIT"
    
    # Source the new configuration
    if [ -f deployment.env ]; then
        source deployment.env
        info "Configuration loaded:"
        info "  Backend: $BACKEND_IMAGE"
        info "  Frontend: $FRONTEND_IMAGE"
        info "  Deployed at: $DEPLOYED_AT"
        info "  Source commit: $COMMIT_SHA"
        
        # Deploy backend if template exists
        if [ -f "/opt/BackendMastery/infra/jobs/personifi-backend.nomad.template" ]; then
            info "🚀 Deploying backend..."
            
            # Generate Nomad job file from template
            sed "s|IMAGE_PLACEHOLDER|$BACKEND_IMAGE|g" \
                "/opt/BackendMastery/infra/jobs/personifi-backend.nomad.template" > \
                "$NOMAD_JOBS_DIR/personifi-backend.nomad"
            
            # Deploy with Nomad
            if nomad job run "$NOMAD_JOBS_DIR/personifi-backend.nomad"; then
                success "Backend deployed successfully"
                
                # Wait for deployment to be healthy
                info "Waiting for backend deployment to be healthy..."
                sleep 10
                
                # Check deployment status
                if nomad job status personifi-backend | grep -q "Status.*running"; then
                    success "Backend is running and healthy"
                else
                    warn "Backend deployment may not be fully healthy"
                fi
            else
                error "Backend deployment failed"
                exit 1
            fi
        else
            warn "Backend template not found at /opt/BackendMastery/infra/jobs/personifi-backend.nomad.template"
        fi
        
        # Deploy frontend if template exists
        if [ -f "/opt/BackendMastery/infra/jobs/personifi-frontend.nomad.template" ]; then
            info "🌐 Deploying frontend..."
            
            # Generate Nomad job file from template
            sed "s|IMAGE_PLACEHOLDER|$FRONTEND_IMAGE|g" \
                "/opt/BackendMastery/infra/jobs/personifi-frontend.nomad.template" > \
                "$NOMAD_JOBS_DIR/personifi-frontend.nomad"
            
            # Deploy with Nomad
            if nomad job run "$NOMAD_JOBS_DIR/personifi-frontend.nomad"; then
                success "Frontend deployed successfully"
                
                # Wait for deployment to be healthy
                info "Waiting for frontend deployment to be healthy..."
                sleep 10
                
                # Check deployment status
                if nomad job status personifi-frontend | grep -q "Status.*running"; then
                    success "Frontend is running and healthy"
                else
                    warn "Frontend deployment may not be fully healthy"
                fi
            else
                error "Frontend deployment failed"
                exit 1
            fi
        else
            warn "Frontend template not found at /opt/BackendMastery/infra/jobs/personifi-frontend.nomad.template"
        fi
        
        success "🎉 Deployment complete: $DEPLOYED_AT"
        info "Both services have been updated to the latest versions"
        
        # Optional: Send deployment notification
        if [ -n "$SLACK_WEBHOOK_URL" ]; then
            curl -X POST -H 'Content-type: application/json' \
                --data "{\"text\":\"✅ Personifi deployed successfully\\nBackend: $BACKEND_IMAGE\\nFrontend: $FRONTEND_IMAGE\\nTime: $DEPLOYED_AT\"}" \
                $SLACK_WEBHOOK_URL
        fi
        
    else
        error "deployment.env not found in deployment repository"
        exit 1
    fi
else
    info "📋 No new deployments (current: $LOCAL_COMMIT)"
fi

# Clean up old generated nomad files (keep last 5)
find $NOMAD_JOBS_DIR -name "*.nomad" -not -name "*.template" -type f -printf '%T@ %p\n' | sort -n | head -n -5 | cut -d' ' -f2- | xargs rm -f 2>/dev/null

info "GitOps deployment check complete"