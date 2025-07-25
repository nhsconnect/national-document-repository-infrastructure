module "ndr-docker-ecr-ui" {
  source   = "./modules/ecr/"
  app_name = "ndr-${terraform.workspace}-app"

  environment = var.environment
  owner       = var.owner
}
module "ndr-docker-ecr-data-collection" {
  count       = local.is_sandbox ? 0 : 1
  source      = "./modules/ecr/"
  app_name    = "${terraform.workspace}-data-collection"
  environment = var.environment
  owner       = var.owner
}
