#!/bin/bash
# ─────────────────────────────────────────────────────────────────
#  EC2 Setup Script — Employee Management System
#  Run this ONCE on your AWS EC2 Ubuntu instance
#  Team: Jesinder (DevOps) & Menaka (Java)
#  Usage: chmod +x ec2-setup.sh && sudo ./ec2-setup.sh
# ─────────────────────────────────────────────────────────────────

set -e
echo "╔══════════════════════════════════════════╗"
echo "║  Setting up EC2 for Employee Mgmt App    ║"
echo "╚══════════════════════════════════════════╝"

# ── Update system ────────────────────────────────────────────────
echo ">>> Updating system..."
apt-get update -y && apt-get upgrade -y

# ── Install Java 17 ──────────────────────────────────────────────
echo ">>> Installing Java 17..."
apt-get install -y openjdk-17-jdk
java -version

# ── Install Maven ────────────────────────────────────────────────
echo ">>> Installing Maven..."
apt-get install -y maven
mvn -version

# ── Install Git ──────────────────────────────────────────────────
echo ">>> Installing Git..."
apt-get install -y git
git --version

# ── Install Docker ───────────────────────────────────────────────
echo ">>> Installing Docker..."
apt-get install -y ca-certificates curl gnupg lsb-release

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
| tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group (no sudo needed)
usermod -aG docker ubuntu

# ── Install Docker Compose (standalone) ──────────────────────────
echo ">>> Installing Docker Compose..."
curl -SL "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-linux-x86_64" \
     -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose --version

# ── Install Jenkins ──────────────────────────────────────────────
echo ">>> Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
     | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
     https://pkg.jenkins.io/debian-stable binary/ \
     | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

apt-get update -y
apt-get install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# Add jenkins to docker group (so Jenkins can run Docker)
usermod -aG docker jenkins

# ── Create app directory ──────────────────────────────────────────
mkdir -p /home/ubuntu/employee-management
chown -R ubuntu:ubuntu /home/ubuntu/employee-management

# ── Configure firewall (UFW) ─────────────────────────────────────
echo ">>> Configuring firewall..."
ufw allow 22      # SSH
ufw allow 80      # Frontend (HTTP)
ufw allow 8080    # Backend API
ufw allow 8081    # Jenkins UI
ufw --force enable

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  ✅ EC2 Setup Complete!                  ║"
echo "╠══════════════════════════════════════════╣"
echo "║  Jenkins URL:  http://$(curl -s ifconfig.me):8081  ║"
echo "║                                          ║"
echo "║  Get Jenkins initial password:           ║"
echo "║  sudo cat /var/lib/jenkins/secrets/      ║"
echo "║            initialAdminPassword          ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "⚠️  IMPORTANT: Restart your terminal/session"
echo "   so docker group changes take effect!"
