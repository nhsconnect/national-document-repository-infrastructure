module "sqs-nrl-queue" {
  source               = "./modules/sqs"
  name                 = "nrl-queue.fifo"
  environment          = var.environment
  owner                = var.owner
  message_retention    = 1209600
  enable_sse           = true
  enable_fifo          = true
  max_visibility       = 601
  enable_deduplication = true
  enable_dlq           = true
  max_receive_count    = 1
}

resource "aws_cloudwatch_metric_alarm" "nrl_dlq_new_messages" {
  alarm_name          = "${terraform.workspace}_NRL_dlq_messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm when there are new messages in the nrl dlq"
  alarm_actions       = [module.nrl-dlq-alarm-topic.arn]

  dimensions = {
    QueueName = module.sqs-nrl-queue.dlq_name
  }
}

module "nrl-dlq-alarm-topic" {
  source                 = "./modules/sns"
  sns_encryption_key_id  = module.sns_encryption_key.id
  topic_name             = "nrl-dlq-topic"
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
          "SNS:Publish",
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

  depends_on = [module.sqs-nrl-queue]
}



