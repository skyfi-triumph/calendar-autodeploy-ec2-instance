locals {
  unique_prefix        = "${var.customer}-${var.application}-${var.stage}-${var.region}"
  tf_state_bucket_name = var.bucket == "" ? "${local.unique_prefix}-terraform-state" : var.bucket
  dynamodb_table_name  = var.dynamodb_table == "" ? "${local.unique_prefix}-ddb-lock-table" : var.dynamodb_table
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "${local.tf_state_bucket_name}-logs"
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = local.tf_state_bucket_name
}

resource "aws_s3_bucket_logging" "terraform_state_bucket" {
  bucket        = aws_s3_bucket.terraform_state_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "/logs"
}

resource "aws_s3_bucket_versioning" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      #tfsec:ignore:AWS017
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      #tfsec:ignore:AWS017
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_acl" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  acl    = var.acl
}

resource "aws_s3_bucket_public_access_block" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "terraform_state_bucket" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = local.dynamodb_table_name
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }
}
