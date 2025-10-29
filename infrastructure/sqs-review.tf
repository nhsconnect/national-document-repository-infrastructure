module "document_review_queue" {
  source                = "./modules/sqs"
  name                  = "document-review"
  max_size_message      = 256 * 1024
  message_retention     = 60 * 60 * 24 * 14 # 14 days
  dlq_message_retention = 60 * 60 * 24 * 14 # 14 days
  environment           = var.environment
  owner                 = var.owner
  max_visibility        = 1020
  enable_dlq            = true
  delay                 = 0
  enable_sse            = true

}

resource "aws_cloudwatch_metric_alarm" "review_dlq_new_messages" {
  alarm_name          = "${terraform.workspace}_review_dlq_messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when there are new messages in the document review dlq"
  alarm_actions       = [module.document_review_dlq_alarm_topic.arn]

  dimensions = {
    QueueName = module.document_review_queue.dlq_name
  }
}

module "document_review_dlq_alarm_topic" {
  source                 = "./modules/sns"
  sns_encryption_key_id  = module.sns_encryption_key.id
  topic_name             = "document_review_dlq_topic"
  topic_protocol         = "email"
  is_topic_endpoint_list = true
  topic_endpoint_list    = nonsensitive(split(",", data.aws_ssm_parameter.cloud_security_notification_email_list.value))
  delivery_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudwatch.amazonaws.com"
        },
        "Action" : [
          "SNS:Publish"
        ],
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        },
        "Resource" : "*"
      }
    ]
  })

  depends_on = [module.document_review_queue]
}
