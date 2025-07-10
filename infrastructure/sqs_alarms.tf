locals {
  monitored_queues = {
    # main queues
    "nrl_main"       = "${terraform.workspace}-nrl-queue.fifo"
    "splunk_main"    = "${terraform.workspace}-splunk-queue"
    "stitching_main" = "${terraform.workspace}-stitching-queue"
    "lg_bulk_main"   = "${terraform.workspace}-lg-bulk-upload-metadata-queue.fifo"
    "lg_inv_main"    = "${terraform.workspace}-lg-bulk-upload-invalid-queue"
    "mns_main"       = "${terraform.workspace}-mns-notification-queue"

    # dead-letter queues
    "nrl_dlq"       = "${terraform.workspace}-deadletter-nrl-queue.fifo"
    "stitching_dlq" = "${terraform.workspace}-deadletter-stitching-queue"
    "mns_dlq"       = "${terraform.workspace}-deadletter-mns-notification-queue"
  }
  days_until_alarm = 6
}
locals {
  is_test_sandbox = contains([], terraform.workspace) # empty list disables sandbox detection, for testing only
}
# TODO: Delete is_test_sandbox, and change all call of is_test_sandbox to is_sandbox

module "global_sqs_age_alarm_topic" {
  count                  = local.is_test_sandbox ? 0 : 1 # TODO:change is_test_sandbox to is_sandbox
  source                 = "./modules/sns"
  sns_encryption_key_id  = module.sns_encryption_key.id
  current_account_id     = data.aws_caller_identity.current.account_id
  topic_name             = "global-sqs-age-alarm-topic"
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
        "Action" : "SNS:Publish",
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        },
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "sqs_oldest_message_alarm" {
  for_each = local.is_test_sandbox ? {} : local.monitored_queues # TODO:change is_test_sandbox to is_sandbox

  alarm_name          = "${terraform.workspace}_${each.key}_oldest_message_alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateAgeOfOldestMessage"
  namespace           = "AWS/SQS"
  period              = 60 # TODO: change to 86400 (24h))
  statistic           = "Maximum"
  threshold           = 60 # TODO: change to local.days_until_alarm*24*60*60
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = each.value
  }

  alarm_description = "Alarm when a message in queue '${each.value}' is older than '${local.days_until_alarm}' days."
  alarm_actions     = [module.global_sqs_age_alarm_topic[0].arn]

  tags = {
    Name        = "${terraform.workspace}_${each.key}_oldest_message_alarm"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}
resource "aws_sns_topic_subscription" "global_sqs_alarm_subscriptions" {
  for_each  = local.is_test_sandbox ? toset([]) : toset(nonsensitive(split(",", data.aws_ssm_parameter.cloud_security_notification_email_list.value))) # TODO:change is_test_sandbox to is_sandbox
  endpoint  = each.value
  protocol  = "email"
  topic_arn = module.global_sqs_age_alarm_topic[0].arn
}


