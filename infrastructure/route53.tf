module "route53_fargate_ui" {
  source                = "./modules/route53"
  environment           = var.environment
  owner                 = var.owner
  domain                = var.domain
  using_arf_hosted_zone = true
  dns_name              = module.ndr-ecs-fargate-app.dns_name

  api_gateway_subdomain_name   = local.api_gateway_subdomain_name
  api_gateway_full_domain_name = aws_api_gateway_domain_name.custom_api_domain.regional_domain_name
  api_gateway_zone_id          = aws_api_gateway_domain_name.custom_api_domain.regional_zone_id
}


resource "aws_route53_record" "ndr_mtls_gateway_api_record" {
  name    = aws_api_gateway_domain_name.mtls_custom_api_domain.domain_name
  type    = "A"
  zone_id = "Z03876441EL64PCVENJO8"

  alias {
    name                   = aws_api_gateway_domain_name.mtls_custom_api_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.mtls_custom_api_domain.regional_zone_id
    evaluate_target_health = true
  }
}