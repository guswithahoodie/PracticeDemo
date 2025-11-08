output "instance_public_ip" {
  value = module.ec2.instance_public_ip
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "app_url" {
  description = "Public URL for the deployed Django app"
  value       = module.ec2.app_url
}
