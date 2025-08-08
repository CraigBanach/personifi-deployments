# GitOps Setup - Server Configuration

## Required Steps to Complete GitOps Setup

### 1. Create the personifi-deployments Repository on GitHub
- [ ] Create new GitHub repository: `personifi-deployments`
- [ ] Push the contents of this directory to the new repo
- [ ] Set repository to public (or ensure server has access)

### 2. Configure Server Environment

#### Install GitOps Script
```bash
# Copy the deployment script to the server
sudo cp /opt/BackendMastery/infra/gitops-deploy.sh /opt/
sudo chmod +x /opt/gitops-deploy.sh
```

#### Create Required Directories
```bash
# Create directory for generated Nomad job files
sudo mkdir -p /opt/nomad-jobs

# Ensure BackendMastery repo is cloned/updated on server
cd /opt && sudo git clone https://github.com/craigbanach/BackendMastery.git
# or if already exists: cd /opt/BackendMastery && sudo git pull
```

#### Set up Cron Job
```bash
# Edit crontab
crontab -e

# Add this line to check for deployments every 2 minutes:
*/2 * * * * /opt/gitops-deploy.sh
```

### 3. Test the Setup

#### Manual Test
```bash
# Run the script manually first to test
sudo /opt/gitops-deploy.sh

# Check the log output
tail -f /var/log/gitops-deploy.log
```

#### Verify Templates Exist
```bash
ls -la /opt/BackendMastery/infra/jobs/*.template
# Should show:
# - personifi-backend.nomad.template
# - personifi-frontend.nomad.template
```

### 4. Configure GitHub Secrets

In your main BackendMastery repository, ensure you have:
- [ ] `GITHUB_TOKEN` - Should already exist for GitHub Actions
- [ ] Repository access permissions for the deployment repo

### 5. Optional Enhancements

#### Slack Notifications (Optional)
```bash
# Set environment variable for Slack webhook
export SLACK_WEBHOOK_URL="your-slack-webhook-url"
# Add to /etc/environment to persist
```

#### Log Rotation
```bash
# Add to /etc/logrotate.d/gitops-deploy
sudo tee /etc/logrotate.d/gitops-deploy << EOF
/var/log/gitops-deploy.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF
```

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