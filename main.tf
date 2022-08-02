provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

locals {
  current_timestamp = timestamp()
  current_day       = formatdate("YYYY-MM-DD", local.current_timestamp)
  unique_prefix     = "${var.customer}-${var.application}-${var.stage}-${var.region}"
  tags = {
    Namespace    = var.namespace,
    "Created By" = "Triumph Tech",
    "Created On" = local.current_day
  }
}
