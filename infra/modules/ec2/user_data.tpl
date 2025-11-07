#!/bin/bash
set -e

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

# Get EC2 instance region from metadata
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | sed -n 's/.*"region"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
echo "Detected region: $REGION" >> /var/log/user-data-debug.log

# Login to ECR
aws ecr get-login-password --region "$REGION" \
  | docker login --username AWS --password-stdin "$ECR_REPO_URL"

# Define image
IMAGE="$ECR_REPO_URL:$IMAGE_TAG"

# Pull latest image
docker pull "$IMAGE"

# Stop previous container if exists
docker rm -f "$PROJECT-container" 2>/dev/null || true

# Run container
docker run -d \
  --name "$PROJECT-container" \
  -p 80:80 \
  --restart unless-stopped \
  "$IMAGE"

# test