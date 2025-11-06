variable "project_name" {
  type        = string
  description = "Project Name"
  default     = "demo_project-task-ai"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "env" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "git_repo" {
  type        = string
  description = "Git repository URL"
  default     = "https://github.com/guswithahoodie/PracticeDemo.git"
}

variable "git_branch" {
  type        = string
  description = "Branch to deploy"
  default     = "main"
}

variable "my_ip" {
  type        = string
  description = "Your public IP in CIDR notation"
  default     = "179.50.178.40/32"
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}