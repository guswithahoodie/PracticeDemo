terraform {
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
  env               = var.env
  vpc_id            = module.vpc.this_vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = var.instance_type
  git_repo          = var.git_repo
  git_branch        = var.git_branch
  my_ip             = var.my_ip_cidr

  ec2_role_name     = module.iam.ec2_role_name
}