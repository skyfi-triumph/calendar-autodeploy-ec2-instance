data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # security group vars
  tcp          = 6
  udp          = 17

  # vpc vars
  vpc_cidr = "10.200.0.0/16"
  vpc_name = join("-", [var.namespace, "vpc"])
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = var.namespace
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]

  create_igw           = true
  enable_dns_hostnames = true

  public_subnet_tags = local.tags

  tags = local.tags
}

module "sg_ec2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = join("-", [var.namespace, "sg"])
  description = "Gaming security group (NICE DCV, Remote Desktop, etc)"
  vpc_id      = module.vpc.vpc_id

  egress_rules = ["all-all"]

  ingress_with_cidr_blocks = flatten([for ip in var.ip_addresses : [
    {
      rule        = "ssh-tcp"
      cidr_blocks = ip
    },
    {
      rule        = "rdp-tcp"
      cidr_blocks = ip
    },
    {
      from_port   = 38810
      to_port     = 38840
      protocol    = local.udp
      description = "Virtual Desktop VR"
      cidr_blocks = ip
    },
    {
      from_port   = 38810
      to_port     = 38840
      protocol    = local.tcp
      description = "Virtual Desktop VR"
      cidr_blocks = ip
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = local.udp
      description = "NiceDCV QUIC"
      cidr_blocks = ip
    },
    {
      from_port   = 8443
      to_port     = 8443
      protocol    = local.tcp
      description = "NiceDCV QUIC"
      cidr_blocks = ip
    },
    {
      from_port   = 8000
      to_port     = 8040
      protocol    = local.udp
      description = "Parsec"
      cidr_blocks = ip
    }
  ]])

  tags = local.tags
}
