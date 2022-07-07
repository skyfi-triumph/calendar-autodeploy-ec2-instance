resource "aws_cloudwatch_event_rule" "cw-dashboard-lambda" {
  name          = "capture-ec2-create-terminate"
  description   = "Trigger Lambda Function when EC2 created/terminated"
  event_pattern = <<EOF
    {
    "source": ["aws.ec2"],
    "detail-type": ["EC2 Instance State-change Notification"],
    "detail": {
        "state": ["running", "terminated"]
    }
    }
    EOF
}

resource "aws_cloudwatch_event_target" "lambda-function-target" {
  target_id = "lambda-function-target"
  rule      = aws_cloudwatch_event_rule.cw-dashboard-lambda.name
  arn       = aws_lambda_function.cw_dashboard_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cw_dashboard_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cw-dashboard-lambda.arn
}