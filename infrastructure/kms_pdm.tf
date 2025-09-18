module "pdm_encryption_key" {
  source              = "./modules/kms"
  kms_key_name        = "alias/pdm-encryption-key-kms-${terraform.workspace}"
  kms_key_description = "Custom KMS Key to enable server side encryption for PDM resources"
  environment         = var.environment
  owner               = var.owner
  service_identifiers = ["ssm.amazonaws.com"]
  kms_deletion_window = var.kms_deletion_window
}
