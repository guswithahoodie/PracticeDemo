variable "project" {}
variable "env" {}
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
variable "vpc_id" {
  type = string
}
variable "ecr_repository_url" {
  type = string
}

variable "image_tag" {
  type    = string
  default = "latest"
}
