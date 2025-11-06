output "user_pool_id" {
  value = aws_cognito_user_pool.auth_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.auth_client.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.task_bucket.bucket
}
