# Nothing much to see here. Modify variables.tf; or better yet, create a .tfvars file
# See https://www.terraform.io/language/values/variables

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

locals {
  current_timestamp = timestamp()
  current_day       = formatdate("YYYY-MM-DD", local.current_timestamp)
  tags = {
    Namespace    = var.namespace,
    "Created By" = "Triumph Tech",
    "Created On" = local.current_day
  }

}