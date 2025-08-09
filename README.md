# Personifi Deployments

This repository manages GitOps deployments for the Personifi application.

## Structure

- `deployment.env` - Contains current deployment configuration
- `nomad/` - Nomad job templates for deployment
- `scripts/` - Deployment scripts

## How it works

1. GitHub Actions builds new images and pushes them to registry
2. GitHub Actions updates `deployment.env` with new image tags
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
# Update deployment.env with desired image tags
git commit -m "Deploy backend abc123 + frontend def456"
git push
```

## Rollback

To rollback to a previous deployment:
```bash
git revert HEAD
git push
``` 
