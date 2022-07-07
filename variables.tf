variable "ec2_count" {
  type = number
}

variable "ami" {
  type = string
}

# variable "ami_owner" {
#   type = string
# }

# variable "ami_filter" {
#   type = string
# }

variable "admin_password" {
  type        = string
  description = "Must adhere to Microsoft Windows password policy"
}

variable "namespace" {
  type = string
}

variable "region" {
  type = string
}

# Security groups are only opened for the IP address of the computer you're running `apply` from. You can change this below,
# or what I do is just update the SG in AWS console if I move to a different location.
# List of actual ip addresses, and "mine" will be tranformed to your current router's IP.
variable "ip_addresses" {
  type = list(string)
}

# The original guide recommended g4dn (2xlarge minimum); a month later, g5 instances were released, 30% faster. That's 
# Nvidia T4 vs A10G GPUs respectively. The G5 instances are A10G GPUs. They're intended for machine learning workloads, not 
# gaming really. But they're RTX chips nonetheless, and absolute MONSTERS. Steam/Oculus will throw "minimum hardware" issues - 
# that's only because they don't recognize the chip; it's unusual for gaming. Ignore that, you can play anything on Ultra.
# ---
# g4dn.2xlarge is cheaper (about $.70/h); g5.2xlarge is stronger (about $1.4/h). See https://aws.amazon.com/ec2/pricing/on-demand/. 
# *.xlarge for 4vcpu/16gb RAM; *.2xlarge for 8vcpu/32gb RAM. IMO, 2xlarge is the sweet spot; less is too little, more is too much.
variable "instance_type" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type = string
}
