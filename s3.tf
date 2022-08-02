resource "aws_s3_bucket" "instance_id_bucket" {
  bucket = "${local.unique_prefix}-instance-ids"
}

resource "aws_s3_bucket_versioning" "instance_id_bucket" {
  bucket = aws_s3_bucket.instance_id_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "instance_id_bucket" {
  bucket = aws_s3_bucket.instance_id_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      #tfsec:ignore:AWS017
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_acl" "instance_id_bucket" {
  bucket = aws_s3_bucket.instance_id_bucket.id
  acl    = "log-delivery-write"
}

#tfsec:ignore:aws-s3-ignore-public-acls
#tfsec:ignore:aws-s3-no-public-buckets
resource "aws_s3_bucket_public_access_block" "instance_id_bucket" {
  bucket = aws_s3_bucket.instance_id_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_for_devs" {
  bucket = aws_s3_bucket.instance_id_bucket.id
  policy = data.aws_iam_policy_document.allow_access_for_devs.json
}

data "aws_iam_policy_document" "allow_access_for_devs" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::{data.aws_caller_identity.current.account_id}:user/SDK-CLI"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.instance_id_bucket.arn,
      "${aws_s3_bucket.instance_id_bucket.arn}/*",
    ]
  }
}