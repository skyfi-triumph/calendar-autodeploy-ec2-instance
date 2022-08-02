variable "ami" {
  type        = string
  description = "AMI of the current Server client wants deployed, which should be put in tfvars."
}

variable "application" {
  type        = string
  description = "A unique identifier to differentiate this deployment."
  default     = ""
}

variable "calendar_id" {
  type        = string
  description = "An email associated with google calendar."
}

variable "customer" {
  type        = string
  description = "A unique identifier to differentiate this deployment."
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "Instance type for gaming instances deployed in environment, which should be updated in tfvars."
}

variable "ip_addresses" {
  type        = list(string)
  description = "IP addresses of all personnel needing access to gaming instances, and IP of on-prem server"
}

variable "namespace" {
  type        = string
  description = "Namespace used for tagging and naming purposes, which should be updated in tfvars."
}

variable "region" {
  type        = string
  description = "Region this solution will be deployed in, which should be updated in tfvars."
}

variable "stage" {
  type        = string
  description = "Stage (aka environment) name, such as 'dev', 'test', or 'prod'"
  default     = ""
}

variable "volume_size" {
  type        = number
  description = "Desired size for volume attached to EC2 instances, which should be updated in tfvars."
}

variable "volume_type" {
  type        = string
  description = "Type of volume attached to EC2 instances, which should be updated in tfvars.  gp2 or gp3"
}
