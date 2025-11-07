#!/bin/bash
set -euxo pipefail
exec > >(tee /var/log/user-data-debug.log|logger -t user-data -s 2>/dev/console) 2>&1

# Variables passed from Terraform
PROJECT="${project}"
ECR_REPO_URL="${ecr_repository_url}"
IMAGE_TAG="${image_tag}"

# Update
dnf update -y

# Install Docker + AWS CLI + SSM Agent
dnf install -y docker amazon-ssm-agent awscli

# Enable services
systemctl enable --now docker
systemctl enable --now amazon-ssm-agent

# Allow ec2-user to use docker
usermod -aG docker ec2-user

# Get EC2 instance region from metadata (retry until available)
for i in {1..10}; do
  REGION=$(curl -s --max-time 2 http://169.254.169.254/latest/dynamic/instance-identity/document | awk -F'"' '/region/ {print $4}')
  if [ -n "$REGION" ]; then
    break
  fi
  echo "Waiting for instance metadata... attempt $i" >> /var/log/user-data-debug.log
  sleep 3
done

echo "Detected region: $REGION" >> /var/log/user-data-debug.log

# Login to ECR (ignore errors temporarily so DB still runs)
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ECR_REPO_URL" || echo "ECR login failed, continuing..."

# Pull latest image (also non-blocking)
docker pull "$ECR_REPO_URL:$IMAGE_TAG" || echo "Docker pull failed, continuing..."

# Stop and remove old containers if exist
docker rm -f postgres-db $${PROJECT}-container 2>/dev/null || true

# Run PostgreSQL container
docker run -d \
  --name postgres-db \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_DB=appdb \
  -v /var/lib/postgresql/data:/var/lib/postgresql/data \
  -p 5432:5432 \
  postgres:15 || echo "Postgres container failed to start!"

# Wait for DB to be ready
sleep 15

# Run Django container, linked to Postgres
docker run -d \
  --name ${project}-container \
  --link postgres-db:db \
  -e DB_NAME=appdb \
  -e DB_USER=admin \
  -e DB_PASSWORD=admin123 \
  -e DB_HOST=postgres-db \
  -e DB_PORT=5432 \
  -p 8000:8000 \
  "$ECR_REPO_URL:$IMAGE_TAG" || echo "Django container failed to start!"
