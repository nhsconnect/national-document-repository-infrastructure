module "ndr-config-backup" {
  source           = "./modules/config/"
  environment      = var.environment
  owner            = var.owner
  is_force_destroy = local.is_force_destroy
  count            = terraform.workspace == "ndra" ? 1 : 0
}