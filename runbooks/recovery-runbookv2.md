# **Personifi Server Recovery Runbook**

This document outlines the architecture, setup, and recovery procedures for the Personifi VPS.

## **🏗 Architecture Overview**

- **Host OS:** Ubuntu 22.04+ LTS
- **Orchestrator:** HashiCorp Nomad (Single node, Server \+ Client mode)
- **Container Runtime:** Docker
- **Ingress/Load Balancer:** Traefik (Running as a Nomad job)
- **Networking:** CNI Plugins (Bridge mode)
- **Deployment Strategy:** GitOps (Polling)
  - A systemd timer triggers /opt/gitops/gitops-deploy.sh every 2 mins.
  - The script checks GitHub for changes to deployment.env.
  - If changes are found, it templates .hcl files and submits them to Nomad.

## **🚨 Emergency Recovery (Total Rebuild)**

If the server is compromised or deleted, follow these steps to restore service.

### **Prerequisites**

1. **DNS:** Ensure your domain points to the new server IP.
2. **Secrets:** Have your DB connection string and GHCR credentials ready.
3. **Access:** You need root SSH access to the new server.

### **Step 1: Bootstrap the Server (Run once)**

1. SSH into the new VPS as root.
2. Run the main setup script (./setup_personifi.sh) that installs Docker, Nomad, and configures the gitops user.
3. Add the new SSH key to GitHub when prompted.

### **Step 2: Create Persistent Secrets File (Manual)**

The automated deployment requires secrets that cannot be stored in the Git repository.

1. Switch to the gitops user:  
   sudo \-u gitops \-i

2. Create the persistent secrets file. **Replace the placeholders with your actual values.**  
   nano /opt/personifi-deployments/.secrets.env

   Content of .secrets.env:

   # Database connection string for the personifi-backend job

   DB_CONNECTION_STRING="Host=your-db-host;Username=postgres;Password=your-db-password;Database=personifi"

   # Credentials for GHCR (Used to pull personifi-backend and personifi-frontend images)

   DOCKER_USERNAME="YOUR_GHCR_USERNAME"  
   DOCKER_PASSWORD="YOUR_GHCR_PAT"

   # Credentials for Auth0

   AUTH0_CLIENT_SECRET="yourAuth0ClientSecret"
   AUTH0_SECRET="yourAuth0Secret"

### **Step 3: Run the Quick Deployment Script (First-Time or Re-Deploy)**

This is the shortcut. It automatically sets Nomad variables, templates jobs, and runs all services.

1. Ensure the quick_deploy.sh script is saved and executable (if you have created this file separately).
2. Run the script as the gitops user:  
   ./quick_deploy.sh

### **Step 4: Verify Deployment**

Check the status of all your services:

nomad job status

## **🔄 Routine Maintenance**

### **Manual Deployment Trigger (Shortcut)**

To force a full deployment check and job submission using the new script:

sudo \-u gitops /opt/personifi-deployments/quick_deploy.sh

### **Checking Deployment Logs**

To monitor the automated deployment process:

tail \-f /var/log/gitops-deploy.log

## **📂 Directory Structure Reference**

| Path                                    | Owner  | Purpose                                                               |
| :-------------------------------------- | :----- | :-------------------------------------------------------------------- |
| /opt/personifi-deployments              | gitops | Cloned Git repository.                                                |
| /opt/personifi-deployments/.secrets.env | gitops | **NEW:** Non-committed file storing application secrets (DB, Docker). |
| /opt/gitops                             | gitops | Home directory for the GitOps user.                                   |
| /etc/nomad.d/nomad.hcl                  | root   | The main configuration file for the Nomad agent.                      |

---

Need to document the traefik config file
