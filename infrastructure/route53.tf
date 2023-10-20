module "route53_fargate_ui" {
  source                = "./modules/route53"
  environment           = var.environment
  owner                 = var.owner
  domain                = var.domain
  certificate_domain    = var.certificate_domain
  using_arf_hosted_zone = true
  dns_name              = module.ndr-ecs-fargate.dns_name
}
