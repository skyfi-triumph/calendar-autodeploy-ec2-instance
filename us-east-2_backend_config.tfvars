acl            = "private"
bucket         = "{var.customer}-{var.application}-{var.stage}-{var.region}-terraform-state"
dynamodb_table = "{var.customer}-{var.application}-{var.stage}-{var.region}-ddb-lock-table"
key            = "terraform.tfstate"
region         = "us-east-2"