#!/bin/bash
# -----------------------------------------------------------------------------
# Observability EC2 user_data: install Docker, clone repo, start stack.
# Rendered by Terraform templatefile() with: github_repo_url, github_branch,
# aws_region, cloudwatch_log_group.
# -----------------------------------------------------------------------------
set -e
export DEBIAN_FRONTEND=noninteractive

GITHUB_REPO_URL="${github_repo_url}"
GITHUB_BRANCH="${github_branch}"
AWS_REGION="${aws_region}"
CLOUDWATCH_LOG_GROUP="${cloudwatch_log_group}"
APP_DIR="/opt/observability-app"

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

echo "==> Cloning repository..."
mkdir -p /opt
if [ -d "$APP_DIR/.git" ]; then
  cd "$APP_DIR" && git fetch && git checkout "$GITHUB_BRANCH" && git pull
else
  git clone -b "$GITHUB_BRANCH" "$GITHUB_REPO_URL" "$APP_DIR"
fi
cd "$APP_DIR"

echo "==> Starting observability stack..."
export AWS_REGION
export CLOUDWATCH_LOG_GROUP

if [ -n "$CLOUDWATCH_LOG_GROUP" ] && [ -f docker-compose.cloudwatch.yml ]; then
  docker compose -f docker-compose.yml -f docker-compose.cloudwatch.yml up -d
else
  docker compose up -d
fi

echo "==> Setup complete. Grafana: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
