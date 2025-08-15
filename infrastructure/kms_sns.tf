module "sns_encryption_key" {
  source              = "./modules/kms"
  kms_key_name        = "alias/alarm-notification-encryption-key-kms-${terraform.workspace}"
  kms_key_description = "Custom KMS Key to enable server side encryption for sns subscriptions"
  environment         = var.environment
  owner               = var.owner
  service_identifiers = ["sns.amazonaws.com", "cloudwatch.amazonaws.com"]
  kms_deletion_window = var.kms_deletion_window
}
