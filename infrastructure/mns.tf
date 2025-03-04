data "aws_ssm_parameter" "mns_lambda_role" {
  name = "/ndr/${var.environment}/mns/lambda_role"
}


module "mns_encryption_key" {
  count                 = 1
  source                = "./modules/kms"
  kms_key_name          = "alias/mns-notification-encryption-key-kms-${terraform.workspace}"
  kms_key_description   = "Custom KMS Key to enable server side encryption for mns subscriptions"
  current_account_id    = data.aws_caller_identity.current.account_id
  environment           = var.environment
  owner                 = var.owner
  service_identifiers   = ["sns.amazonaws.com"]
  aws_identifiers       = [data.aws_ssm_parameter.mns_lambda_role.value]
  allow_decrypt_for_arn = true
}

module "sqs-mns-notification-queue" {
  count                  = 1
  source                 = "./modules/sqs"
  name                   = "mns-notification-queue"
  max_size_message       = 256 * 1024        # allow message size up to 256 KB
  message_retention      = 60 * 60 * 24 * 14 # 14 days
  environment            = var.environment
  owner                  = var.owner
  max_visibility         = 1020
  delay                  = 60
  enable_sse             = null
  kms_master_key_id      = module.mns_encryption_key[0].id
  enable_dlq             = true
  dlq_visibility_timeout = 0
  max_receive_count      = 3
}

resource "aws_sqs_queue_policy" "mns_sqs_access" {
  count = 1

  queue_url = module.sqs-mns-notification-queue[0].sqs_url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = data.aws_ssm_parameter.mns_lambda_role.value
        },
        Action   = "SQS:SendMessage",
        Resource = module.sqs-mns-notification-queue[0].sqs_arn
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "msn_dlq_new_message" {
  alarm_name          = "${terraform.workspace}_MNS_dlq_messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Alarm for when there are new messages in the MNS DLQ"
  alarm_actions       = [module.mns-dlq-alarm-topic.arn]

  dimensions = {
    QueueName = module.sqs-mns-notification-queue[0].dlq_name
  }
}

module "mns-dlq-alarm-topic" {
  source                 = "./modules/sns"
  sns_encryption_key_id  = module.sns_encryption_key.id
  current_account_id     = data.aws_caller_identity.current.account_id
  topic_name             = "mns-dlq-topic"
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
  depends_on = [module.sqs-mns-notification-queue[0]]
}
