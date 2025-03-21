module "ndr-docker-ecr-ui" {
  source             = "./modules/ecr/"
  app_name           = "ndr-${terraform.workspace}-app"
  current_account_id = data.aws_caller_identity.current.account_id

  environment = var.environment
  owner       = var.owner
}
module "ndr-docker-ecr-weekly-ods-update" {
  count              = local.is_sandbox ? 0 : 1
  source             = "./modules/ecr/"
  app_name           = "${terraform.workspace}-weekly-ods-update"
  current_account_id = data.aws_caller_identity.current.account_id
  environment        = var.environment
  owner              = var.owner
}
