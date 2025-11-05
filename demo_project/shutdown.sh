#!/bin/bash
set -euo pipefail

PROJECT="demo_project-task-ai-dev"
REGION="us-east-1"
DRY_RUN=${DRY_RUN:-true}  # Set DRY_RUN=false to actually delete resources

echo "Shutting down AWS demo project: $PROJECT in region $REGION"
if [ "$DRY_RUN" = true ]; then
    echo "DRY RUN mode enabled. No resources will actually be deleted."
fi

###########################################
# Helper functions
###########################################
execute() {
    local cmd="$1"
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] $cmd"
    else
        eval "$cmd"
    fi
}

retry_command() {
    local cmd="$1"
    local retries=${2:-5}
    local delay=${3:-5}
    local attempt=1

    until eval "$cmd"; do
        if [ $attempt -ge $retries ]; then
            echo "Command failed after $attempt attempts: $cmd"
            return 1
        fi
        echo "Retry $attempt/$retries in $delay sec..."
        sleep $delay
        attempt=$((attempt+1))
    done
}

###########################################
# ECS Services
###########################################
services=$(aws ecs list-services --cluster "${PROJECT}-cluster" --region "$REGION" --query 'serviceArns' --output text)
for service in $services; do
    echo "Stopping service: $service"
    execute "aws ecs update-service --cluster ${PROJECT}-cluster --service $service --desired-count 0 --force-new-deployment --region $REGION"
    execute "aws ecs wait services-stable --cluster ${PROJECT}-cluster --services $service --region $REGION"
    execute "aws ecs delete-service --cluster ${PROJECT}-cluster --service $service --region $REGION --force"
    echo "Deleted ECS service: $service"
done

###########################################
# ALBs & Target Groups
###########################################
lbs=$(aws elbv2 describe-load-balancers --region "$REGION" --query "LoadBalancers[?contains(LoadBalancerName, '${PROJECT}')].LoadBalancerArn" --output text)
for lb in $lbs; do
    listeners=$(aws elbv2 describe-listeners --load-balancer-arn "$lb" --region "$REGION" --query 'Listeners[].ListenerArn' --output text)
    for listener in $listeners; do
        execute "aws elbv2 delete-listener --listener-arn $listener --region $REGION"
        echo "Deleted listener: $listener"
    done
    execute "aws elbv2 delete-load-balancer --load-balancer-arn $lb --region $REGION"
    echo "Deleted ALB: $lb"
done

tgs=$(aws elbv2 describe-target-groups --region "$REGION" --query "TargetGroups[?contains(TargetGroupName, '${PROJECT}')].TargetGroupArn" --output text)
for tg in $tgs; do
    execute "aws elbv2 delete-target-group --target-group-arn $tg --region $REGION"
    echo "Deleted target group: $tg"
done

###########################################
# Security Groups
###########################################
sgs=$(aws ec2 describe-security-groups --region "$REGION" --filters "Name=group-name,Values=${PROJECT}*" --query 'SecurityGroups[].GroupId' --output text)
for sg in $sgs; do
    echo "Deleting security group: $sg"
    retry_command "execute \"aws ec2 delete-security-group --group-id $sg --region $REGION\"" 10 5
    echo "Deleted security group: $sg"
done

###########################################
# ECR Repositories
###########################################
repos=$(aws ecr describe-repositories --region "$REGION" --query "repositories[?contains(repositoryName, '${PROJECT}')].repositoryName" --output text)
for repo in $repos; do
    echo "Checking images in ECR repo: $repo"
    images=$(aws ecr list-images --repository-name "$repo" --region "$REGION" --query 'imageIds' --output json)
    if [ "$images" != "[]" ]; then
        execute "aws ecr batch-delete-image --repository-name $repo --image-ids '$images' --region $REGION"
    fi
    execute "aws ecr delete-repository --repository-name $repo --region $REGION --force"
    echo "Deleted ECR repository: $repo"
done

###########################################
# VPCs, Subnets, Internet Gateways
###########################################
vpcs=$(aws ec2 describe-vpcs --region "$REGION" --filters "Name=tag:Name,Values=${PROJECT}*" --query 'Vpcs[].VpcId' --output text)
for vpc in $vpcs; do
    echo "Cleaning VPC: $vpc"

    igws=$(aws ec2 describe-internet-gateways --filters "Name=attachment.vpc-id,Values=$vpc" --region "$REGION" --query 'InternetGateways[].InternetGatewayId' --output text)
    for igw in $igws; do
        execute "aws ec2 detach-internet-gateway --internet-gateway-id $igw --vpc-id $vpc --region $REGION"
        execute "aws ec2 delete-internet-gateway --internet-gateway-id $igw --region $REGION"
    done

    subnets=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpc" --region "$REGION" --query 'Subnets[].SubnetId' --output text)
    for subnet in $subnets; do
        execute "aws ec2 delete-subnet --subnet-id $subnet --region $REGION"
    done

    retry_command "execute \"aws ec2 delete-vpc --vpc-id $vpc --region $REGION\"" 10 5
    echo "Deleted VPC: $vpc"
done

echo "All resources for $PROJECT have been cleaned up (or dry run executed)."
