variable "region" { default = "us-east-1" }
variable "project" {
  type    = string
  default = "gus_demo_project"
}
variable "env" { default = "dev" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnets" { default = ["10.0.1.0/24","10.0.2.0/24"] }
variable "azs" { default = ["us-east-1a","us-east-1b"] }
variable "my_ip_cidr" { default = "104.28.94.55/32" }
