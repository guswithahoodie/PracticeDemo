output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "ecr_repo" {
  value = aws_ecr_repository.app.repository_url
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}

output "db_password" {
  value = random_password.db_password.result
  sensitive = true
}
