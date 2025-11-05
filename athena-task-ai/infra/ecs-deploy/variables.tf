variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "athena-task-ai"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro" # cheap dev option
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
