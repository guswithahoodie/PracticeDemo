variable "project" {}
variable "env" {}
variable "vpc_id" {}
variable "public_subnet_ids" { type = list(string) }
variable "instance_type" { default = "t3.micro" }
variable "git_repo" {}
variable "git_branch" { default = "dev" }
variable "my_ip" {}
