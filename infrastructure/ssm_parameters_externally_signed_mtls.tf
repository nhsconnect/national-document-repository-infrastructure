# Creating Params to hold a copy of externally signed client cert and key
module "ssm_param_external_client_cert" {
  # count       = var.externally_signed_certs ? 1 : 0
  source         = "./modules/ssm_parameter"
  environment    = var.environment
  owner          = var.owner
  name           = "external_client_cert"
  type           = "SecureString"
  description    = "Externally signed client certificate for mTLS"
  value          = "REPLACE_ME"
  key_id         = module.sns_encryption_key.key_id
  ignore_changes = ["value"]
}

module "ssm_param_external_client_key" {
  # count       = var.externally_signed_certs ? 1 : 0
  source         = "./modules/ssm_parameter"
  environment    = var.environment
  owner          = var.owner
  name           = "external_client_key"
  type           = "SecureString"
  description    = "Externally signed client certificate for mTLS"
  value          = "REPLACE_ME"
  key_id         = module.sns_encryption_key.key_id
  ignore_changes = ["value"]
}