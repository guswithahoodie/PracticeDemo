variable "project" {}
variable "env" {}
variable "vpc_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "instance_type" {}
variable "git_repo" {}
variable "git_branch" {}
variable "my_ip" {}
variable "ec2_role_name" {
  description = "IAM role name to attach to EC2 instance"
  type        = string
}
