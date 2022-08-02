resource "aws_cloudwatch_event_rule" "cw-dashboard-lambda" {
  name          = "capture-ec2-create-terminate"
  description   = "Triggers Lambda Function when EC2 instance created/terminated"
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

resource "aws_lambda_permission" "allow_cw_events_to_invoke_lambda_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cw_dashboard_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cw-dashboard-lambda.arn
}

resource "aws_cloudwatch_event_rule" "trigger-calendar-event-lambda" {
  name                = "trigger-calendar-event-lambda"
  description         = "Triggers calendar_pull_event Lambda Function every 15 minutes."
  schedule_expression = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "trigger-calendar-event-target" {
  target_id = "trigger-calendar-event-target"
  rule      = aws_cloudwatch_event_rule.trigger-calendar-event-lambda.name
  arn       = aws_lambda_function.calendar_pull_event_function.arn
}

resource "aws_lambda_permission" "allow_cw_events_to_invoke_calendar_lambda_function" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.calendar_pull_event_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.trigger-calendar-event-lambda.arn
}