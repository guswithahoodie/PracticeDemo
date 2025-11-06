output "ec2_role_name" {
  value = aws_iam_role.ec2_role.name
}
# infra/modules/iam/outputs.tf
output "ecr_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}
