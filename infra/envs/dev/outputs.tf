output "instance_public_ip" {
  value = aws_instance.app.public_ip
  description = "Public IP of EC2 instance"
}

output "instance_id" {
  value = aws_instance.app.id
}
