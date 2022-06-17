state         = "stop" #stop for first build, then init to start and get credentials
namespace     = "objective-reality-gaming"
region        = "us-east-1"
ip_addresses  = ["mine"]
instance_type = "g5.xlarge"
spot_price    = null # "2.0"
volume_size   = 250
volume_type   = "gp3"

ami = "default"
#ami = "ami-0e70ed1f1258f9821" # raw