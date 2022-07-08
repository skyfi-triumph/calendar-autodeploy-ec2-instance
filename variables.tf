variable "ami" {
  type = string
}

variable "namespace" {
  type = string
}

variable "region" {
  type = string
}

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
