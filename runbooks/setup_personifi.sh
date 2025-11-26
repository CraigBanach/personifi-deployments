#!/bin/bash

# ==========================================
# Personifi Server Setup Script v2
# Installs: Users, Firewall, Docker, Nomad, CNI, GitOps
# ==========================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configuration
ADMIN_USER="craig"
GITOPS_USER="gitops"
GITOPS_HOME="/opt/gitops"
DEPLOY_REPO="git@github.com:craigbanach/personifi-deployments.git"
DEPLOY_DIR="/opt/personifi-deployments"
NOMAD_VERSION="1.6.3" # Pinning a stable version is safer, or remove to get latest

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root.${NC}"
   exit 1
fi

echo -e "${GREEN}Starting Personifi VPS Setup (Full Rebuild)...${NC}"

# ==========================================
# 1. System Hardening & Dependencies
# ==========================================
echo -e "${YELLOW}1. Updating system and installing base dependencies...${NC}"
apt-get update && apt-get upgrade -y
apt-get install -y ufw fail2ban git curl unzip wget gnupg lsb-release ca-certificates

echo -e "${YELLOW}1.2 Configuring Firewall (UFW)...${NC}"
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp          # SSH
ufw allow 80/tcp          # HTTP (Traefik)
ufw allow 443/tcp         # HTTPS (Traefik)
ufw allow 4646:4648/tcp   # Nomad (RPC/Serf/HTTP)
echo "y" | ufw enable

# ==========================================
# 2. Install Docker (Runtime)
# ==========================================
echo -e "${YELLOW}2. Installing Docker Engine...${NC}"
if ! command -v docker &> /dev/null; then
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    echo -e "${GREEN}Docker installed successfully.${NC}"
else
    echo "Docker already installed."
fi

# ==========================================
# 3. Install Nomad & CNI Plugins
# ==========================================
echo -e "${YELLOW}3. Installing Nomad & CNI Plugins...${NC}"
if ! command -v nomad &> /dev/null; then
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    
    apt-get update
    apt-get install -y nomad
    
    # Install CNI Plugins (Required for Nomad bridge networking)
    echo "Installing CNI plugins..."
    curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-$(dpkg --print-architecture)-v1.3.0.tgz"
    mkdir -p /opt/cni/bin
    tar -C /opt/cni/bin -xzf cni-plugins.tgz
    rm cni-plugins.tgz
else
    echo "Nomad already installed."
fi

# ==========================================
# 4. User Setup
# ==========================================
echo -e "${YELLOW}4. Configuring Users...${NC}"

# Admin User
if ! id "$ADMIN_USER" &>/dev/null; then
    adduser --disabled-password --gecos "" $ADMIN_USER
    usermod -aG sudo,docker $ADMIN_USER
    echo -e "${GREEN}User $ADMIN_USER created.${NC}"
fi

# GitOps User
if ! id "$GITOPS_USER" &>/dev/null; then
    adduser --system --home $GITOPS_HOME --shell /bin/bash --group $GITOPS_USER
    usermod -aG docker $GITOPS_USER # Allow gitops to manage docker if needed
fi

mkdir -p $GITOPS_HOME
chown $GITOPS_USER:$GITOPS_USER $GITOPS_HOME
chmod 750 $GITOPS_HOME

# ==========================================
# 5. SSH Setup (Interactive)
# ==========================================
echo -e "${YELLOW}5. Setting up SSH for GitHub...${NC}"
sudo -u $GITOPS_USER mkdir -p $GITOPS_HOME/.ssh
sudo -u $GITOPS_USER chmod 700 $GITOPS_HOME/.ssh
KEY_PATH="$GITOPS_HOME/.ssh/id_ed25519"

if [ ! -f "$KEY_PATH" ]; then
    sudo -u $GITOPS_USER ssh-keygen -t ed25519 -f $KEY_PATH -N ""
fi

sudo -u $GITOPS_USER ssh-keyscan -t ed25519 github.com > $GITOPS_HOME/.ssh/known_hosts
chown $GITOPS_USER:$GITOPS_USER $GITOPS_HOME/.ssh/known_hosts

echo -e "\n${RED}!!! ACTION REQUIRED !!!${NC}"
echo "Add this key to GitHub Deploy Keys: https://github.com/craigbanach/personifi-deployments/settings/keys"
echo "----------------------------------------------------------------"
cat $KEY_PATH.pub
echo "----------------------------------------------------------------"
echo -e "${YELLOW}Press [Enter] once the key is added to GitHub...${NC}"
read -p ""

# ==========================================
# 6. Clone Repo & Apply Infra Configs
# ==========================================
echo -e "${YELLOW}6. Cloning Repository & Applying Configs...${NC}"
mkdir -p $DEPLOY_DIR
chown -R $GITOPS_USER:$GITOPS_USER $DEPLOY_DIR
mkdir -p /opt/nomad/jobs
chown -R $GITOPS_USER:$GITOPS_USER /opt/nomad

if [ -d "$DEPLOY_DIR/.git" ]; then
    sudo -u $GITOPS_USER git -C $DEPLOY_DIR pull
else
    sudo -u $GITOPS_USER -i git clone $DEPLOY_REPO $DEPLOY_DIR || { echo -e "${RED}Git clone failed!${NC}"; exit 1; }
fi

# --- CRITICAL: Apply Nomad Configuration ---
if [ -f "$DEPLOY_DIR/infra/nomad.hcl" ]; then
    echo "Applying Nomad configuration from repository..."
    cp "$DEPLOY_DIR/infra/nomad.hcl" /etc/nomad.d/nomad.hcl
    # Ensure data dir exists
    mkdir -p /opt/nomad/data
    chown nomad:nomad /opt/nomad/data
else
    echo -e "${RED}Warning: infra/nomad.hcl not found. Using default Nomad config.${NC}"
fi

# --- Apply Traefik Configuration ---
# Assuming Traefik runs as a job, but if it needs static config:
if [ -f "$DEPLOY_DIR/infra/traefik/traefik.yml" ]; then
    echo "Staging Traefik configuration..."
    mkdir -p /etc/traefik
    cp "$DEPLOY_DIR/infra/traefik/traefik.yml" /etc/traefik/traefik.yml
fi

# Enable and Start Nomad
systemctl enable --now nomad
echo -e "${GREEN}Nomad started.${NC}"

# ==========================================
# 7. Install GitOps Automation
# ==========================================
echo -e "${YELLOW}7. Installing GitOps Service...${NC}"
touch /var/log/gitops-deploy.log
chown $GITOPS_USER:$GITOPS_USER /var/log/gitops-deploy.log

SCRIPT_SOURCE="$DEPLOY_DIR/scripts/gitops-deploy.sh"
SCRIPT_DEST="$GITOPS_HOME/gitops-deploy.sh"

if [ -f "$SCRIPT_SOURCE" ]; then
    cp $SCRIPT_SOURCE $SCRIPT_DEST
    chown $GITOPS_USER:$GITOPS_USER $SCRIPT_DEST
    chmod 700 $SCRIPT_DEST
else
    echo -e "${RED}ERROR: gitops-deploy.sh not found in repo!${NC}"
fi

# Systemd Service
cat <<EOF > /etc/systemd/system/gitops-deploy.service
[Unit]
Description=Personifi GitOps Deployment
After=network.target nomad.service

[Service]
Type=oneshot
User=$GITOPS_USER
WorkingDirectory=$GITOPS_HOME
Environment=HOME=$GITOPS_HOME
ExecStart=$GITOPS_HOME/gitops-deploy.sh
StandardOutput=journal
StandardError=journal
EOF

# Systemd Timer
cat <<EOF > /etc/systemd/system/gitops-deploy.timer
[Unit]
Description=Run GitOps Deployment every 2 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=2min
Unit=gitops-deploy.service

[Install]
WantedBy=timers.target
EOF

systemctl daemon-reload
systemctl enable --now gitops-deploy.timer

# ==========================================
# 8. Final Check
# ==========================================
echo -e "\n${GREEN}Setup Complete!${NC}"
echo "Nomad Status:"
nomad node status
echo ""
echo "GitOps Timer Status:"
systemctl status gitops-deploy.timer --no-pager