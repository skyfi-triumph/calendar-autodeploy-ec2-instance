provider "aws" {
  region = var.region
}

data "aws_caller_identity" "this_account" {
  provider = aws
}

data "aws_region" "current" {}
