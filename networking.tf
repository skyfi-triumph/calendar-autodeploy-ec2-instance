data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  vpc_cidr = "10.200.0.0/16"
  vpc_name = join("-", [var.namespace, "vpc"])
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

#tfsec:ignore:aws-vpc-no-excessive-port-access tfsec:ignore:aws-vpc-no-public-ingress-acl
module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 3.0"
  name                 = var.namespace
  cidr                 = local.vpc_cidr
  azs                  = local.azs
  public_subnets       = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  create_igw           = true
  enable_dns_hostnames = true
  public_subnet_tags   = local.tags
  tags                 = local.tags
}


resource "aws_security_group" "vr_server-access" {
  name        = join("-", [var.namespace, "sg"])
  description = "RDP security group (NICE DCV, Remote Desktop, etc)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8040
    protocol    = "udp"
    description = "Parsec"
    cidr_blocks = var.ip_addresses
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    description = "NiceDCV QUIC"
    cidr_blocks = var.ip_addresses
  }

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "udp"
    description = "NiceDCV QUIC"
    cidr_blocks = var.ip_addresses
  }

  ingress {
    from_port   = 38810
    to_port     = 38840
    protocol    = "tcp"
    description = "Virtual Desktop VR"
    cidr_blocks = var.ip_addresses
  }

  ingress {
    from_port   = 38810
    to_port     = 38840
    protocol    = "udp"
    description = "Virtual Desktop VR"
    cidr_blocks = var.ip_addresses
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "udp"
    description = "RDP"
    cidr_blocks = var.ip_addresses
  }
  #tfsec:ignore:aws-vpc-no-public-egress-sgr
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    description = "Allow All Outgoing Traffic"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}