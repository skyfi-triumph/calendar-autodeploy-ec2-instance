# Configured via "partial backend config" via CLI:
# terraform init -backend-config=backend_config.tfvars
terraform {
  backend "s3" {
    encrypt = true
  }
}

# https://stackoverflow.com/questions/56962133/can-terraform-backend-fields-be-accessed-as-variables
# terraform init -backend-config=backend_config.tfvars # create state using backend variables
# terraform plan -var-file={your varfile} -var-file=backend_config.tfvars # reference the backend config variables
