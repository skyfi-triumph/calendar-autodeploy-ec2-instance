###### Lambda function to create/update CloudWatch Dashboard ######
data "archive_file" "cw_dashboard_function" {
  type        = "zip"
  source_file = "${path.module}/cw_dashboard_function/cw_dashboard.py"
  output_path = "cw_dashboard.zip"
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "cw_dashboard_function" {
  description      = "Creates CloudWatch Dashboard for EC2 Custom/GPU Metrics"
  function_name    = "cw_dashboard"
  filename         = "cw_dashboard.zip"
  source_code_hash = data.archive_file.cw_dashboard_function.output_base64sha256
  role             = aws_iam_role.cw_dashboard_function.arn
  runtime          = "python3.8"
  handler          = "cw_dashboard.lambda_handler"
  timeout          = 60
  tags             = local.tags
  environment {
    variables = {
      AWS_REGION_FOR_CW_DASHBOARD = var.region
    }
  }
  lifecycle {
    ignore_changes = [
      source_code_hash,
      tags
    ]
  }
}

#### Lambda function to pull event from Google Calendar ###
resource "null_resource" "build_lambda_zip" {
  triggers = {
    calendar_pull_event_hash = filesha256("${path.module}/event_pull_code/calendar_pull_event.py")
  }
  provisioner "local-exec" {
    command     = "${path.module}/event_pull_code/build_lambda_zip.sh"
    interpreter = ["bash", "-c"]
  }
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "calendar_pull_event_function" {
  description      = "Creates CloudWatch Event Rules from Google Calendar entries"
  function_name    = "calendar_pull_event"
  filename         = "${path.module}/event_pull_code/calendar_pull_event.zip"
  source_code_hash = filesha256("${path.module}/event_pull_code/calendar_pull_event.zip")
  role             = aws_iam_role.calendar_pull_function.arn
  runtime          = "python3.8"
  handler          = "calendar_pull_event.lambda_handler"
  timeout          = 60
  tags             = local.tags
  environment {
    variables = {
      REGION      = var.region
      CALENDAR_ID = var.calendar_id
      AWS_ACCOUNT = data.aws_caller_identity.current.account_id
    }
  }
  depends_on = [
    null_resource.build_lambda_zip
  ]
}

###### Lambda function to create EC2 instance ######
data "archive_file" "ec2_start_stop_function" {
  type        = "zip"
  source_file = "${path.module}/ec2_start_stop_function/ec2_start_stop_function.py"
  output_path = "ec2_start_stop_function.zip"
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "ec2_start_stop_function" {
  description      = "Creates EC2 instance"
  function_name    = "ec2_start_stop_function"
  filename         = "ec2_start_stop_function.zip"
  source_code_hash = data.archive_file.ec2_start_stop_function.output_base64sha256
  role             = aws_iam_role.ec2_start_stop_function.arn
  runtime          = "python3.8"
  handler          = "ec2_start_stop_function.lambda_handler"
  timeout          = 120
  environment {
    variables = {
      AMI                       = var.ami
      INSTANCE_TYPE             = var.instance_type
      SUBNET_ID                 = element(module.vpc.public_subnets, 0)
      REGION                    = var.region
      VOLUME_SIZE               = var.volume_size
      VOLUME_TYPE               = var.volume_type
      AZ                        = module.vpc.azs[0]
      SUBNET_ID                 = module.vpc.public_subnets[0]
      VPC_SG_IDS                = aws_security_group.vr_server-access.id
      IAM_INSTANCE_PROFILE_NAME = aws_iam_instance_profile.ec2.name
      IAM_INSTANCE_PROFILE_ARN  = aws_iam_instance_profile.ec2.arn
      S3_BUCKET_INSTANCE_ID     = aws_s3_bucket.instance_id_bucket.id
      CUSTOMER                  = var.customer
      APPLICATION               = var.application
      STAGE                     = var.stage
      AWS_ACCOUNT               = data.aws_caller_identity.current.account_id
    }
  }
  tags = local.tags
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatchEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ec2_start_stop_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${var.region}:${data.aws_caller_identity.current.account_id}:rule/*"
}