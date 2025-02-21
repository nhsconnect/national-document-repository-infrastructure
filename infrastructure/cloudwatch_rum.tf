module "cloudwatch_rum" {
  source = "./modules/cloudwatch_rum/"
  count = local.is_production ? 0 : 1
}
