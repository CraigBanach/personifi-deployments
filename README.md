# Personifi Deployments

This repository manages GitOps deployments for the Personifi application.

## Structure

- `deployment.env` - Contains Personifi and legacy nopCommerce configuration
- `environments/tcg-medusa-production.env` - TCG Medusa production deployment manifest
- `nomad/` - Nomad job templates for deployment
- `scripts/` - Deployment scripts

## How it works

1. GitHub Actions builds new images and pushes them to registry
2. GitHub Actions updates the relevant tracked deployment manifest with new image references
3. Server polls this repo and deploys when changes are detected

## Deployment History

Each deployment is tracked as a Git commit with:
- Backend image tag
- Frontend image tag
- Deployment timestamp
- Source commit SHA

## Manual Deployment

To deploy a specific version:
```bash
# Update deployment.env or environments/tcg-medusa-production.env
git commit -m "Deploy backend abc123 + frontend def456"
git push
```

## Rollback

To rollback to a previous deployment:
```bash
git revert HEAD
git push
``` 
