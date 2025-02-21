module "cloudwatch_rum" {
  source = "./modules/cloudwatch_rum/"
  count = local.is_production ? 1 : 0
}
