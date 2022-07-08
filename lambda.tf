###### Encryption Key for EC2 instances ######

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

###### Lambda function to create/update CloudWatch Dashboard ######

data "archive_file" "python_lambda_package" {
  type        = "zip"
  source_file = "${path.module}/code/lambda_function.py"
  output_path = "cw_dashboard.zip"
}

resource "aws_lambda_function" "cw_dashboard_function" {
  description      = "Creates CloudWatch Dashboard for EC2 Custom/GPU Metrics"
  function_name    = "ec2CWDashboardUpdater"
  filename         = "cw_dashboard.zip"
  source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.7"
  handler          = "lambda_function.lambda_handler"
  timeout          = 60

  tags = local.tags

}

###### Lambda function to create EC2 instance ######

data "archive_file" "python_lambda_package_ec2" {
  type        = "zip"
  source_file = "${path.module}/code/ec2_lambda.py"
  output_path = "ec2_lambda.zip"
}

resource "aws_lambda_function" "ec2_create_function" {
  description      = "Creates EC2 instance"
  function_name    = "ec2Create"
  filename         = "ec2_lambda.zip"
  source_code_hash = data.archive_file.python_lambda_package_ec2.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  runtime          = "python3.7"
  handler          = "ec2_lambda.lambda_handler"
  timeout          = 600
  environment {
    variables = {
      AMI                       = var.ami
      INSTANCE_TYPE             = var.instance_type
      KEY_NAME                  = aws_key_pair.key_pair.key_name
      SUBNET_ID                 = element(module.vpc.public_subnets, 0)
      REGION                    = var.region
      VOLUME_SIZE               = var.volume_size
      VOLUME_TYPE               = var.volume_type
      AZ                        = module.vpc.azs[0]
      SUBNET_ID                 = module.vpc.public_subnets[0]
      VPC_SG_IDS                = module.sg_ec2.security_group_id
      IAM_INSTANCE_PROFILE_NAME = aws_iam_instance_profile.this.name
      IAM_INSTANCE_PROFILE_ARN  = aws_iam_instance_profile.this.arn
    }
  }

  tags = local.tags

}
