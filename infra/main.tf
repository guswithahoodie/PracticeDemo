terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- Cognito User Pool for Authentication ---
resource "aws_cognito_user_pool" "auth_pool" {
  name = "${var.project_name}-user-pool"
}

# App client (allows app to auth against the user pool)
resource "aws_cognito_user_pool_client" "auth_client" {
  name         = "${var.project_name}-client"
  user_pool_id = aws_cognito_user_pool.auth_pool.id
  generate_secret = false
}

# --- S3 Bucket for Task Attachments ---
resource "aws_s3_bucket" "task_bucket" {
  bucket = "${var.project_name}-task-bucket"
  force_destroy = true
}

# --- IAM Role for Lambda Execution ---
resource "aws_iam_role" "lambda_exec_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# --- VPC Networking ---
module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
}

# --- IAM for EC2 ---
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}

# --- EC2 Instance for Django API ---
module "ec2" {
  source = "./modules/ec2"
  subnet_id      = module.vpc.subnet_id
  security_group = module.vpc.security_group
  ec2_role_name  = module.iam.ec2_role_name   # <--- pass the IAM role name from IAM module
  project_name   = var.project_name
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

