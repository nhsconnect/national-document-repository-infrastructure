module "sqs-stitching-queue" {
  source                = "./modules/sqs"
  name                  = "stitching-queue"
  environment           = var.environment
  owner                 = var.owner
  message_retention     = 1209600
  dlq_message_retention = 1209600
  enable_sse            = true
  max_visibility        = 1200
  enable_dlq            = true
}

resource "aws_cloudwatch_metric_alarm" "stitching_dlq_new_messages" {
  alarm_name          = "${terraform.workspace}_stitching_dlq_messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when there are new messages in the stitching dlq"
  alarm_actions       = [module.stitching-dlq-alarm-topic.arn]

  dimensions = {
    QueueName = module.sqs-stitching-queue.dlq_name
  }
}

module "stitching-dlq-alarm-topic" {
  source                 = "./modules/sns"
  sns_encryption_key_id  = module.sns_encryption_key.id
  topic_name             = "stitching-dlq-topic"
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
        }
        "Resource" : "*"
      }
    ]
  })

  depends_on = [module.sqs-stitching-queue]
}
