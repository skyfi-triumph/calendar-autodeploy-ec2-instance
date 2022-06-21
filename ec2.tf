data "aws_ami" "cloudxr" {
  owners      = ["aws-marketplace"]
  most_recent = true

  filter {
    name = "name"
    #values = ["DCV-Windows-*-NVIDIA-gaming-*"]  #owner=amazon
    values = ["win2019-server-vWS-472.39-cloudxr-v3.1_ami2-*"] #owner=aws-marketplace
  }
}

# Use this data block after creating own AMI from Objective Reality Games setup
# data "aws_ami" "nice_dcv" {
#   owners = ["366706138918"]
#   most_recent = true

#   filter {
#     name   = "name"
#     #values = ["ami-072a1ef11a6493c1b"]
#     values = ["*-ORG-*"]
#   }
# }

resource "tls_private_key" "key" {
  algorithm = "RSA"
}
resource "local_sensitive_file" "private_key" {
  filename        = "./${var.namespace}.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "0400"
}
resource "aws_key_pair" "key_pair" {
  key_name   = var.namespace
  public_key = tls_private_key.key.public_key_openssh
  tags       = local.tags
}

module "ec2" {
  count = var.state == "init" ? 1 : 0

  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "${var.namespace}-${local.current_day}"

  ami                         = var.ami == "default" ? data.aws_ami.nice_dcv.id : var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key_pair.key_name
  availability_zone           = local.az
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.sg_ec2.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  get_password_data           = var.ami == "default"
  user_data                   = templatefile("gpuMetrics.txt", {})

  create_spot_instance                = var.spot_price == null ? false : true
  spot_price                          = var.spot_price
  spot_instance_interruption_behavior = var.spot_price == null ? null : "stop"

  root_block_device = [
    {
      volume_type = var.volume_type
      volume_size = var.volume_size
    },
  ]

  tags = local.tags
}

resource "aws_eip" "eip" {
  instance = var.state == "init" || var.state == "start" ? module.ec2[0].id : null
  vpc      = true
  tags     = local.tags
}

resource "aws_ami_from_instance" "snapshot" {
  count = var.state == "snapshot" || var.state == "stop" ? 1 : 0
  name               = var.namespace
  source_instance_id = module.ec2[0].id
  tags = {
  local.tags,
  Name = "${local.current_day}-ORG-${var.instance_type}"
  }
}


