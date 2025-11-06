#!/bin/bash
set -e

# Variables passed from Terraform:
# ${project}
# ${ecr_repository_url}
# ${image_tag}

# Update and install required packages
dnf update -y
dnf install -y docker amazon-ssm-agent

# Enable services
systemctl enable --now docker
systemctl enable --now amazon-ssm-agent

# Allow ec2-user to run docker
usermod -aG docker ec2-user

# Determine region automatically
REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/region)"

# Login to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ecr_repository_url}

# Define image name with tag
IMAGE="${ecr_repository_url}:${image_tag}"

# Pull the container image
docker pull $IMAGE

# Stop old container if exists
if docker ps -a --format '{{.Names}}' | grep -q "^${project}-container$"; then
  docker rm -f ${project}-container || true
fi

# Run container exposed on port 80
docker run -d \
  --name ${project}-container \
  -p 80:80 \
  --restart unless-stopped \
  $IMAGE
