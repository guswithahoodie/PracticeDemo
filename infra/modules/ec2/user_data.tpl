#!/bin/bash
set -e

# Variables passed from Terraform:
# ${project}
# ${ecr_repository_url}
# ${image_tag}

dnf update -y
dnf install -y docker amazon-linux-extras

systemctl enable --now docker
usermod -a -G docker ec2-user

# Login to ECR (region provided by AWS metadata)
REGION="$(curl -s http://169.254.169.254/latest/meta-data/placement/region)"
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin ${ecr_repository_url}

IMAGE="${ecr_repository_url}:${image_tag}"

# Pull latest image from ECR
docker pull $IMAGE

# Stop and remove existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${project}-container$"; then
  docker rm -f ${project}-container || true
fi

# Run container
docker run -d \
  --name ${project}-container \
  -p 80:80 \
  --restart unless-stopped \
  $IMAGE
