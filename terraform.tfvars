state          = "init" #stop for first build, then init to start and get credentials, snapshot to create ami
namespace      = "objective-reality-gaming"
region         = "us-east-1"
ip_addresses   = ["mine"]
instance_type  = "g5.xlarge"
spot_price     = null # "2.0"
volume_size    = 250
volume_type    = "gp3"
ami_owner      = "amazon"                        # for cloudxr "aws-marketplace"
ami_filter     = "DCV-Windows-*-NVIDIA-gaming-*" # for cloudxr "win2019-server-vWS-472.39-cloudxr-v3.1_ami2-*"
admin_password = "dxHr-&M2qX777772AVY-pRO2Rt23?-WM"

ami = "default"
#ami = "ami-0e70ed1f1258f9821" # raw