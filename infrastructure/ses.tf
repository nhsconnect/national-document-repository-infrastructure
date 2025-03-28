locals {
  domain_prefix = terraform.workspace
  domain        = "${local.domain_prefix}.${var.domain}"
}

module "ndr-feedback-mailbox" {
  source        = "./modules/ses"
  domain_prefix = local.domain_prefix
  domain        = local.domain
  zone_id       = module.route53_fargate_ui.zone_id
  enable        = !local.is_sandbox
}