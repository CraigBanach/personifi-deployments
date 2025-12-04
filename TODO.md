# GitOps Setup - Server Configuration

## How It Works

1. **Developer pushes code** → GitHub Actions builds images
2. **GitHub Actions updates** `deployment.env` in this repo
3. **Cron job runs** `/opt/gitops-deploy.sh` every 2 minutes
4. **Script detects changes** and deploys using Nomad templates
5. **Templates generate** actual Nomad jobs with specific image tags
6. **Nomad deploys** the new versions

## Troubleshooting

### Check Script Execution

```bash
# View recent log entries
tail -20 /var/log/gitops-deploy.log

# Run script with verbose output
bash -x /opt/gitops-deploy.sh
```

### Verify Repository Access

```bash
# Test git clone/pull manually
cd /tmp && git clone https://github.com/craigbanach/personifi-deployments.git
```

### Check Nomad Status

```bash
# View job status
nomad job status personifi-backend
nomad job status personifi-frontend
```

## Rollback Process

To rollback to a previous deployment:

```bash
cd /opt/personifi-deployments
git log --oneline  # Find the commit to rollback to
git revert HEAD    # Rollback the latest deployment
git push           # GitOps will detect and deploy the rollback
```

# Add admin user key ssh setup to runbook
