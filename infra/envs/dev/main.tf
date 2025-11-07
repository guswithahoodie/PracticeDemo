terraform {
  backend "s3" {
    bucket         = "gus-demo-project-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "gus-demo-project-tflock"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source        = "../../modules/vpc"
  project       = var.project
  env           = var.env
  vpc_cidr      = var.vpc_cidr
  public_subnets = var.public_subnets
  azs           = var.azs
}

module "iam" {
  source  = "../../modules/iam"
  project = var.project
  env     = var.env
}

module "ec2" {
  source            = "../../modules/ec2"

  project           = var.project
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids

  my_ip_cidr        = var.my_ip_cidr
  ecr_repository_url = "043656069964.dkr.ecr.${var.region}.amazonaws.com/${var.project}"
  image_tag          = "latest"
  ec2_role_name      = module.iam.ec2_role_name
}
