variable "region" {
  type        = string
  description = "The AWS Region in which to deploy the remote backend resources."
}

variable "bucket" {
  type        = string
  description = "Name of the Terraform state bucket. This will override the automatic naming based on customer, application, and stage! Leave blank to use auto-generated name."
  default     = ""
}

variable "dynamodb_table" {
  type        = string
  description = "Name of the Terraform lock table. This will override the automatic naming based on customer, application, and stage! Leave blank to use auto-generated name."
  default     = ""
}

variable "acl" {
  type        = string
  description = "ACL of the S3 bucket. Defaults to `bucket-owner-full-control`"
  default     = "bucket-owner-full-control"
}

variable "customer" {
  type        = string
  description = "A unique identifier to differentiate this deployment."
  default     = ""
}

variable "application" {
  type        = string
  description = "A unique identifier to differentiate this deployment."
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage (aka environment) name, such as 'dev', 'Test', or 'Production'"
  default     = ""
}
