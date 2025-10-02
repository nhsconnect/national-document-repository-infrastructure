# Creating Params to hold a copy of externally signed client cert and key
module "ssm_param_external_client_cert" {
  count                = local.is_sandbox ? 0 : 1
  source               = "./modules/ssm_parameter"
  environment          = var.environment
  owner                = var.owner
  name                 = "external_client_cert"
  type                 = "SecureString"
  description          = "Externally signed client certificate for mTLS"
  value                = "REPLACE_ME"
  key_id               = module.pdm_encryption_key.id
  ignore_value_changes = true
}

module "ssm_param_external_client_key" {
  count                = local.is_sandbox ? 0 : 1
  source               = "./modules/ssm_parameter"
  environment          = var.environment
  owner                = var.owner
  name                 = "external_client_key"
  type                 = "SecureString"
  description          = "Externally signed client certificate for mTLS"
  value                = "REPLACE_ME"
  key_id               = module.pdm_encryption_key.id
  ignore_value_changes = true
}