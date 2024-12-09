data "aws_ssm_parameter" "mns_lambda_role" {
  name = "/ndr/${var.environment}/mns/lambda_role"
}


module "mns_encryption_key" {
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
  source            = "./modules/sqs"
  name              = "mns-notification-queue"
  max_size_message  = 256 * 1024        # allow message size up to 256 KB
  message_retention = 60 * 60 * 24 * 14 # 14 days
  environment       = var.environment
  owner             = var.owner
  max_visibility    = 1020
  delay             = 60
  enable_sse        = null
  kms_master_key_id = module.mns_encryption_key.id
}

resource "aws_sqs_queue_policy" "mns_sqs_access" {
  queue_url = module.sqs-mns-notification-queue.sqs_url

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = data.aws_ssm_parameter.mns_lambda_role.value
        },
        Action   = "SQS:SendMessage",
        Resource = module.sqs-mns-notification-queue.sqs_arn
      }
    ]
  })
}
