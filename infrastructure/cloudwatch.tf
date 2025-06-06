module "cloudwatch" {
  source                    = "./modules/cloudwatch"
  cloudwatch_log_group_name = "/aws/api-gateway/access-logs"
  environment               = var.environment
  owner                     = var.owner
}
