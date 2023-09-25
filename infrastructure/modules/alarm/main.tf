resource "aws_cloudwatch_metric_alarm" "lambda_error" {
  alarm_name        = "${terraform.workspace}-alarm_${var.lambda_name}_error"
  alarm_description = "Triggers when an error has occurred in ${var.lambda_function_name}."
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  namespace           = var.namespace
  metric_name         = "Errors"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "0"
  period              = "300"
  evaluation_periods  = "1"
  statistic           = "Sum"
  actions_enabled     = "true"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration_alarm" {
  alarm_name        = "${terraform.workspace}-alarm_${var.lambda_name}_duration"
  alarm_description = "Triggers when duration of ${var.lambda_function_name} exceeds 80% of timeout."
  dimensions = {
    FunctionName = var.lambda_function_name
  }
  threshold           = var.lambda_timeout * 0.8 * 1000
  namespace           = var.namespace
  metric_name         = "Duration"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = "300"
  evaluation_periods  = "1"
  statistic           = "Maximum"
}

resource "aws_cloudwatch_metric_alarm" "lambda_memory_alarm" {
  alarm_name        = "${terraform.workspace}-alarm_${var.lambda_name}_memory"
  alarm_description = "Triggers when max memory usage of ${var.lambda_function_name} exceeds 80% of provisioned memory."
  dimensions = {
    function_name = var.lambda_function_name
  }
  threshold           = 80
  namespace           = "LambdaInsights"
  metric_name         = "memory_utilization"
  comparison_operator = "GreaterThanThreshold"
  period              = "300"
  evaluation_periods  = "1"
  statistic           = "Maximum"
}
