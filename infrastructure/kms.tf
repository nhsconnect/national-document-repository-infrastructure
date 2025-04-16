module "sns_encryption_key" {
  source              = "./modules/kms"
  kms_key_name        = "alias/alarm-notification-encryption-key-kms-${terraform.workspace}"
  kms_key_description = "Custom KMS Key to enable server side encryption for sns subscriptions"
  current_account_id  = data.aws_caller_identity.current.account_id
  environment         = var.environment
  owner               = var.owner
  service_identifiers = ["sns.amazonaws.com", "cloudwatch.amazonaws.com"]
}

module "logs_encryption_key" {
  source              = "./modules/kms"
  kms_key_name        = "alias/logs-encryption-key-kms-${terraform.workspace}"
  kms_key_description = "Custom KMS Key to enable server side encryption for CloudWatch log groups and S3 access logs"
  current_account_id  = data.aws_caller_identity.current.account_id
  environment         = var.environment
  owner               = var.owner
  service_identifiers = ["logs.${var.region}.amazonaws.com", "s3.amazonaws.com"]
}