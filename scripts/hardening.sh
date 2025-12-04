#!/bin/bash
set -e

# --- Configuration ---
SSH_CONFIG="/etc/ssh/sshd_config"

echo "🔒 Starting Server Hardening..."

# 1. SSH Hardening
echo "   -> Hardening SSH configuration..."
# Backup config
cp $SSH_CONFIG "$SSH_CONFIG.bak"

# Disable Root Login
sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG
# Disable Password Authentication (Force SSH Keys)
sed -i 's/^PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG
sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG
sed -i 's/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' $SSH_CONFIG
# Disable Empty Passwords
sed -i 's/^PermitEmptyPasswords.*/PermitEmptyPasswords no/' $SSH_CONFIG

# Restart SSH to apply changes
systemctl restart ssh
echo "   ✅ SSH locked down (Root login & Passwords disabled)."

# 2. Firewall Cleanup (Close Management Ports)
echo "   -> Closing management ports (8080, 4646)..."
# We leave 80, 443, and 22 open.
ufw delete allow 8080/tcp || true  # Traefik Dashboard
ufw delete allow 4646:4648/tcp || true # Nomad UI/RPC
# Re-confirm standard ports
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw reload
echo "   ✅ Firewall updated. Dashboards are now hidden from public internet."

# 3. Enable Unattended Upgrades (Security Patches)
echo "   -> Enabling automatic security updates..."
apt-get install -y unattended-upgrades
echo 'Unattended-Upgrade::Allowed-Origins {
        "${distro_id}:${distro_codename}-security";
        "${distro_id}ESMApps:${distro_codename}-apps-security";
        "${distro_id}ESM:${distro_codename}-infra-security";
};' > /etc/apt/apt.conf.d/50unattended-upgrades-custom
systemctl enable --now unattended-upgrades
echo "   ✅ Auto-updates enabled."

# 4. Ensure Fail2Ban is running
echo "   -> Checking Fail2Ban..."
systemctl enable --now fail2ban
echo "   ✅ Fail2Ban is active."

echo "🎉 Hardening Complete. Please test SSH access as user 'craig'."