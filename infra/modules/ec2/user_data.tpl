#!/bin/bash
set -e

# Basic deps
yum update -y
yum install -y git docker

systemctl enable --now docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

cd /home/ec2-user
if [ -d "${project}" ]; then
  rm -rf ${project}
fi

# Clone chosen branch
git clone --depth 1 -b ${git_branch} ${git_repo} ${project}
chown -R ec2-user:ec2-user ${project}
cd ${project}/backend

# Build docker image and run
docker build -t ${project}-image .
# Stop existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${project}-container$"; then
  docker rm -f ${project}-container || true
fi

# Run container mapping host 80 to container 80
docker run -d --name ${project}-container -p 80:80 --restart unless-stopped ${project}-image
