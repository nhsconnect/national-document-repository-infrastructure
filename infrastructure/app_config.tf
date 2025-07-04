module "ndr-app-config" {
  source                  = "./modules/app_config"
  environment             = var.environment
  owner                   = var.owner
  config_environment_name = terraform.workspace
  config_profile_name     = "config-profile-${terraform.workspace}"
  dev_config_enabled      = !local.is_production
}