# data "aws_ami" "vr-gaming" {
#   owners      = [var.ami_owner]
#   most_recent = true

#   filter {
#     name   = "name"
#     values = [var.ami_filter]
#   }
# }

# Use this data block after creating own AMI from Objective Reality Games setup
# data "aws_ami" "vr-gaming" {
#   owners = ["366706138918"]
#   most_recent = true

#   filter {
#     name   = "name"
#     #values = ["ami-072a1ef11a6493c1b"]
#     values = ["*-ORG-*"]
#   }
# }

# module "ec2" {
#   count = var.state == "init" ? var.ec2_count : 0

#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 3.0"

#   name = "${var.namespace}-${local.current_day}-${count.index}"

#   ami                         = var.ami == "default" ? data.aws_ami.vr-gaming.id : var.ami
#   instance_type               = var.instance_type
#   key_name                    = aws_key_pair.key_pair.key_name
#   availability_zone           = element(module.vpc.azs, 0)
#   subnet_id                   = element(module.vpc.public_subnets, 0)
#   vpc_security_group_ids      = [module.sg_ec2.security_group_id]
#   associate_public_ip_address = true
#   iam_instance_profile        = aws_iam_instance_profile.this.name
#   get_password_data           = var.ami == "default"
#   user_data                   = templatefile("code/gpuMetrics.txt", { admin_password = var.admin_password })

#   root_block_device = [
#     {
#       volume_type = var.volume_type
#       volume_size = var.volume_size
#     }
#   ]

#   tags = local.tags
# }

# resource "aws_eip" "eip" {
#   count    = var.ec2_count
#   instance = var.state == "init" || var.state == "start" ? module.ec2[count.index].id : null
#   vpc      = true
#   tags     = local.tags
# }
