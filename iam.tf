locals {
  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
  ]
}

# EC2 Instance Profile for SSM and CloudWatch
resource "aws_iam_instance_profile" "ec2" {
  name = "${local.unique_prefix}-Instance-Profile-CloudWatch-SSM"
  role = aws_iam_role.ec2.name
}

# Role used by Instance Profile above
resource "aws_iam_role" "ec2" {
  name = "${local.unique_prefix}-instance-role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "ec2" {
  count      = length(local.role_policy_arns)
  role       = aws_iam_role.ec2.name
  policy_arn = element(local.role_policy_arns, count.index)
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "ec2" {
  name = "${local.unique_prefix}-ec2-policy"
  role = aws_iam_role.ec2.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "cloudwatchAccess",
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:GetDashboard",
            "cloudwatch:ListDashboards",
            "cloudwatch:PutDashboard",
            "cloudwatch:DeleteDashboards",
            "cloudwatch:ListMetrics",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:GetMetricData",
            "cloudwatch:Describe*",
            "cloudwatch:PutMetricData"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

# CW Dashboard Lambda Function
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role" "cw_dashboard_function" {
  name = "${local.unique_prefix}-lambdaRole-cwdashboard"
  path = "/"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          }
        }
      ]
    }
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "cw_dashboard_function" {
  name = "${local.unique_prefix}-cw_dashboard_function-policy"
  role = aws_iam_role.cw_dashboard_function.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "cloudwatchAccess",
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:GetDashboard",
            "cloudwatch:PutDashboard",
            "cloudwatch:DeleteDashboards",
            "cloudwatch:ListMetrics",
            "cloudwatch:Describe*",
            "cloudwatch:PutMetricData"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "ec2Access",
          "Effect" : "Allow",
          "Action" : "ec2:DescribeInstances",
          "Resource" : "*"
        },
        {
          "Sid" : "lambdaAccess",
          "Effect" : "Allow",
          "Action" : "lambda:InvokeFunction",
          "Resource" : "*"
        },
        {
          "Sid" : "iamPass",
          "Effect" : "Allow",
          "Action" : [
            "iam:GetRole",
            "iam:PassRole"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "logsAccess",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:CreateLogGroup"
          ],
          "Resource" : "arn:aws:logs:*:*:*"
        }
      ]
    }
  )
}

# EC2 Start / Stop Lambda Function
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role" "ec2_start_stop_function" {
  name = "${local.unique_prefix}-ec2_start_stop_function"
  path = "/"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : ["lambda.amazonaws.com", "events.amazonaws.com"]
          }
        }
      ]
    }
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "ec2_start_stop_function" {
  name = "${local.unique_prefix}-ec2_start_stop_function-policy"
  role = aws_iam_role.ec2_start_stop_function.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "ec2Access",
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeInstances",
            "ec2:ModifyInstanceAttribute",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:RunInstances",
            "ec2:TerminateInstances",
            "ec2:AssociateIamInstanceProfile",
            "ec2:CreateVolume",
            "ec2:AttachVolume",
            "ec2:DescribeImages",
            "ec2:DescribeVolumes",
            "ec2:AssociateAddress",
            "ec2:DescribeAddresses",
            "ec2:DescribeRouteTables",
            "ec2:CreateTags",
            "ec2:Describe*",
            "ec2:Search*",
            "ec2:Get*",
            "iam:ListInstanceProfiles"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "iamPass",
          "Effect" : "Allow",
          "Action" : [
            "iam:GetRole",
            "iam:PassRole"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "lambdaAccess",
          "Effect" : "Allow",
          "Action" : "lambda:InvokeFunction",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : "arn:aws:s3:::*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:deleteLogStream",
            "logs:deleteLogGroup",
            "logs:deleteMetricFilter",
            "logs:deleteQueryDefinition",
            "logs:deleteRetentionPolicy",
            "logs:describeLogGroups",
            "logs:DescribeLogStreams",
            "logs:describeMetricFilters",
            "logs:getLogEvents",
            "logs:putMetricFilter",
            "logs:putQueryDefinition"
          ],
          "Resource" : "arn:aws:logs:*:*:*"
        },
        {
          "Sid" : "eventsAccess",
          "Effect" : "Allow",
          "Action" : "events:*",
          "Resource" : "*"
        }
      ]
    }
  )
}

# Calendar Pull/Create Event Lambda Function
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role" "calendar_pull_function" {
  name = "${local.unique_prefix}-lambdaRole-calendar_pull_function"
  path = "/"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "lambda.amazonaws.com"
          }
        }
      ]
    }
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "calendar_pull_function" {
  name = "${local.unique_prefix}-calendar_pull_function-policy"
  role = aws_iam_role.calendar_pull_function.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "cloudwatchAccess",
          "Effect" : "Allow",
          "Action" : [
            "cloudwatch:GetDashboard",
            "cloudwatch:PutDashboard",
            "cloudwatch:DeleteDashboards",
            "cloudwatch:ListMetrics",
            "cloudwatch:Describe*",
            "cloudwatch:PutMetricData"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "ec2Access",
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeInstances",
            "ec2:ModifyInstanceAttribute",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:RunInstances",
            "ec2:TerminateInstances",
            "ec2:AssociateIamInstanceProfile",
            "ec2:CreateVolume",
            "ec2:AttachVolume",
            "ec2:DescribeImages",
            "ec2:DescribeVolumes",
            "ec2:AssociateAddress",
            "ec2:DescribeAddresses",
            "ec2:DescribeRouteTables",
            "ec2:CreateTags",
            "ec2:Describe*",
            "ec2:Search*",
            "ec2:Get*"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "eventsAccess",
          "Effect" : "Allow",
          "Action" : "events:*",
          "Resource" : "*"
        },
        {
          "Sid" : "lambdaAccess",
          "Effect" : "Allow",
          "Action" : "lambda:InvokeFunction",
          "Resource" : "*"
        },
        {
          "Sid" : "iamPass",
          "Effect" : "Allow",
          "Action" : [
            "iam:GetRole",
            "iam:PassRole"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : "ssm:GetParameters",
          "Resource" : "*"
        },
        {
          "Sid" : "logsAccess",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:CreateLogGroup"
          ],
          "Resource" : "arn:aws:logs:*:*:*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
            "secretsmanager:ListSecretVersionIds",
            "secretsmanager:TagResource",
            "secretsmanager:UntagResource"
          ],
          "Resource" : "arn:aws:secretsmanager:*:366706138918:secret:google-calendar-serviceaccount-Nn3F0c"
        }
      ]
    }
  )
}

# EventBridge Rule Role
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role" "eventbridge_for_lambda" {
  name = "${local.unique_prefix}-eventbridge_for_lambda"
  path = "/"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : ["events.amazonaws.com", "lambda.amazonaws.com"]
          }
        }
      ]
    }
  )
}

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "eventbridge_role_for_lambda_execution" {
  name = "${local.unique_prefix}-eventbridge_for_lambda-policy"
  role = aws_iam_role.eventbridge_for_lambda.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "ec2Access",
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeInstances",
            "ec2:ModifyInstanceAttribute",
            "ec2:StartInstances",
            "ec2:StopInstances",
            "ec2:RunInstances",
            "ec2:TerminateInstances",
            "ec2:AssociateIamInstanceProfile",
            "ec2:CreateVolume",
            "ec2:AttachVolume",
            "ec2:DescribeImages",
            "ec2:DescribeVolumes",
            "ec2:AssociateAddress",
            "ec2:DescribeAddresses",
            "ec2:DescribeRouteTables",
            "ec2:CreateTags",
            "ec2:Describe*",
            "ec2:Search*",
            "ec2:Get*",
            "iam:ListInstanceProfiles"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "iamPass",
          "Effect" : "Allow",
          "Action" : [
            "iam:GetRole",
            "iam:PassRole"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "eventsAccess",
          "Effect" : "Allow",
          "Action" : "events:*",
          "Resource" : "*"
        },
        {
          "Sid" : "lambdaAccess",
          "Effect" : "Allow",
          "Action" : "lambda:InvokeFunction",
          "Resource" : "*"
        },
        {
          "Sid" : "s3Access",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject"
          ],
          "Resource" : "arn:aws:s3:::*"
        }
      ]
    }
  )
}