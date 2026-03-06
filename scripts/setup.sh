#!/bin/bash
# -----------------------------------------------------------------------------
# EC2 user_data: install Docker only. No git clone; deployment is via Jenkins
# (push images to Docker Hub, scp compose + config, pull and run on server).
# -----------------------------------------------------------------------------
set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Updating packages and installing Docker..."
apt-get update -qq
apt-get install -qq -y ca-certificates curl gnupg lsb-release
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list
apt-get update -qq
apt-get install -qq -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "==> Enabling Docker and adding ubuntu to docker group..."
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

echo "==> Creating app directory (Jenkins will deploy compose + config via SSH)"
mkdir -p /opt/observability-app
chown ubuntu:ubuntu /opt/observability-app

echo "==> Setup complete. Run first deploy from Jenkins (Deploy to EC2 stage)."
