output "instance_public_ip" {
  value = aws_instance.app.public_ip
}

output "instance_id" {
  value = aws_instance.app.id
}

output "app_url" {
  description = "Public URL for the deployed Django app"
  value       = "http://${aws_instance.app.public_ip}:8000"
}

output "security_group_id" {
  value = aws_security_group.app_sg.id
}
