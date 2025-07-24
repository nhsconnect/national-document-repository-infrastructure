resource "aws_cloudwatch_metric_alarm" "api_gateway_alarm_4XX" {
  alarm_name          = "4XX-status-${aws_api_gateway_rest_api.ndr_doc_store_api.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/ApiGateway"
  metric_name         = "4XXError"
  period              = 60
  statistic           = "Sum"
  threshold           = 20
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.ndr_doc_store_api.name
    Stage   = var.environment
  }

  alarm_description = "This alarm indicates that at least 20 4XX statuses have occurred on ${aws_api_gateway_rest_api.ndr_doc_store_api.name} in a minute."
  alarm_actions     = [aws_sns_topic.alarm_notifications_topic[0].arn]

  tags = {
    Name        = "4XX-status-${aws_api_gateway_rest_api.ndr_doc_store_api.name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
  count = local.is_sandbox ? 0 : 1
}

resource "aws_cloudwatch_metric_alarm" "api_gateway_alarm_5XX" {
  alarm_name          = "5XX-status-${aws_api_gateway_rest_api.ndr_doc_store_api.name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  namespace           = "AWS/ApiGateway"
  metric_name         = "5XXError"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  treat_missing_data  = "notBreaching"

  dimensions = {
    ApiName = aws_api_gateway_rest_api.ndr_doc_store_api.name
    Stage   = var.environment
  }

  alarm_description = "This alarm indicates that at least 5 5XX statuses have occurred on ${aws_api_gateway_rest_api.ndr_doc_store_api.name} within 5 minutes."
  alarm_actions     = [aws_sns_topic.alarm_notifications_topic[0].arn]

  tags = {
    Name        = "5XX-status-${aws_api_gateway_rest_api.ndr_doc_store_api.name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
  count = local.is_sandbox ? 0 : 1
}

resource "aws_sns_topic" "alarm_notifications_topic" {
  name_prefix       = "${terraform.workspace}-alarms-notification-topic-"
  kms_master_key_id = module.sns_encryption_key.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudwatch.amazonaws.com"
        },
        "Action" : "SNS:Publish",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
        "Resource" : "*"
      }
    ]
  })
  count = local.is_sandbox ? 0 : 1
}

resource "aws_sns_topic_subscription" "alarm_notifications_sns_topic_subscription" {
  for_each  = local.is_sandbox ? [] : toset(nonsensitive(split(",", data.aws_ssm_parameter.cloud_security_notification_email_list.value)))
  endpoint  = each.value
  protocol  = "email"
  topic_arn = local.is_sandbox ? "" : aws_sns_topic.alarm_notifications_topic[0].arn
}

data "aws_ssm_parameter" "cloud_security_notification_email_list" {
  name = "/prs/${var.environment}/user-input/cloud-security-notification-email-list"
}