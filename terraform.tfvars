state          = "init" #stop for first build, then init to start and get credentials, snapshot to create ami
namespace      = "objective-reality-gaming"
region         = "us-east-1"
ip_addresses   = ["mine"]
instance_type  = "g5.xlarge"
volume_size    = 250
volume_type    = "gp3"
ami_owner      = "amazon"                        # for cloudxr "aws-marketplace"
ami_filter     = "DCV-Windows-*-NVIDIA-gaming-*" # for cloudxr "win2019-server-vWS-472.39-cloudxr-v3.1_ami2-*"
admin_password = "TheAbstract22!"
ec2_count      = 1

ami = "default"
#ami = "ami-0e70ed1f1258f9821" # raw