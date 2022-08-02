output "terraform_state_bucket_name" {
  value = aws_s3_bucket.terraform_state_bucket.id
}

output "terraform_state_log_bucket_name" {
  value = aws_s3_bucket.log_bucket.id
}

