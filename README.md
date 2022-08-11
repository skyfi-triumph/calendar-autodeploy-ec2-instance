# Automated VR Gaming Server Creation from Google Calendar Entries

- [Contents](#contents)
- [Preliminary Setup](#preliminary-setup)
- [Setup Terraform Backend](#setup-terraform-backend)
- [Setup Bitbucket Pipeline](#setup-bitbucket-pipeline)
- [Access EC2 with NiceDCV](#access-ec2-with-nicedcv)
- [Google Calendar Entry Requirements](#google-calendar-entry-requirements)

This repository contains a solution to create and destroy VR Gaming Servers based on Google calendar entries, with CloudWatch custom GPU metrics displayed on a CloudWatch Dashboard.  All static resources are deployed with Infrastructure as Code using Terraform and a BitBucket Pipeline. By leveraging AWS Lambda Functions, the creation and deletion of servers is handled automatically based on entries in the designated Google Calendar.

# Contents

* Deploys infrastructure using Terraform and a Bitbucket Pipeline
* Uses calendar_pull_event.py Lambda Function to pull data from a Google calendar and create EventBridge Rule to trigger ec2_start_stop_function.py Lambda Function
* Uses ec2_start_stop_function.py Lambda Function to create EC2 instance from specified AMI, create EventBridge Rule to destroy instance at End Time from Google Calendar entry, and publish instance details to S3 in json format
* Uses cw_dashboard.py Lambda Function to create/update CloudWatch Dashboard with metrics of all running instances with desired tag

# Preliminary Setup

1. **Install and configure the AWS CLI**
    * Follow these instructions to install: [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
    * Configure the CLI: [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html#cli-quick-configuration)
2. **Install and configure Terraform**
    * Use the instructions on Terraform website for installing: [Terraform Installation](https://www.terraform.io/downloads)
3. **Create Bitbucket Repo**
    * Use the instructions on BitBucket website for account setup: [Bitbucket Setup](https://www.bitbucket.org)
4. **Create VR Gaming AMI**
    * From AWS Console, launch preferred Microsoft Windows g4dn or g5 EC2 instance with cw_dashboard_function/gpuMetrics.txt as userdata (add admin_password inside script to set login password) or login to new instance and run script with PowerShell, which sends customer CloudWatch Metrics to AWS
    * Install all software and files required for gaming server
    * Create AMI and copy to all desired regions
    * For each region copied to, create EC2 instance from AMI, run gpuMetrics.txt script, then create new AMI from that instance

# Setup Terraform Backend

1. **Create tfvars for desired region in backend_setup directory**
    * Set region, customer, application, and stage (example: us-east-1_backend_config.tfvars)
2. **Apply backend_setup Terraform via CLI**
    * From backend_setup directory and AWS_PROFILE set, run terraform init, terraform apply --approve
3. **Create backend.tfvars file in base directory**
    * Create backend.tfvars file in base directory to point to S3 Bucket and DynamoDB Table created in previous step (example: us-east-1_backend_config.tfvars)

# Setup Bitbucket Pipeline

1. **Setup Bitbucket Pipeline YAML script**
    * Open `bitbucket-pipelines.yml` in your favourite text editor
    * Setup a `step` under the main branch for each desired region
2. **Add AWS Credentials to Repository Variables**
    * Create AWS user with Programmatic Access and save access key ID and secret access key
    * Add those credentials to Bitbucket (Repository settings/Repository variables)
3. **Update tfvars for each region**
    * Update the tfvars files for each region you are deploying to, including adding your IP address for accessing the servers
4. **Push code to Bitbucket repo**
    * Push your code to Bitbucket and it should see your bitbucket-pipelines.yml file and trigger the pipeline build

# Access EC2 with NiceDCV

1. **Download NiceDCV**
    * Select appropriate download for your computer at https://download.nice-dcv.com/
2. **Connect to EC2 Instance**
    * Login using public IP of EC2 instance, username: Administrator, password: password used in gpuMetrics.txt

# Google Calendar Entry Requirements

1. **Required Inputs**
    * Entry should have Start/End Times, Username, Instance Type, and Region
    * User@example.com
    * g4dn.xlarge
    * us-east-1
2. **Output to S3**
    * After instance creation, a json object is saved to S3 in location: {user}/{REGION}/{now_unix_timestamp}
    * JSON object contains User, Region, Public IP, Instance ID, and Start Time