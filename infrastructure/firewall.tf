module "firewall_waf_v2" {
  source         = "./modules/firewall_waf_v2"
  cloudfront_acl = false
  environment    = var.environment
  owner          = var.owner
  count          = local.is_sandbox ? 0 : 1
}

module "firewall_waf_v2_api" {
  source         = "./modules/firewall_waf_v2"
  cloudfront_acl = false
  environment    = var.environment
  owner          = var.owner
  count          = local.is_sandbox ? 0 : 1
  api            = true
}

resource "aws_wafv2_web_acl_association" "web_acl_association" {
  resource_arn = module.ndr-ecs-fargate-app.load_balancer_arn
  web_acl_arn  = module.firewall_waf_v2[0].arn
  count        = local.is_sandbox ? 0 : 1
  depends_on = [
    module.ndr-ecs-fargate-app,
    module.firewall_waf_v2[0]
  ]
}

resource "aws_wafv2_web_acl_association" "api_gateway" {
  resource_arn = aws_api_gateway_stage.ndr_api.arn
  web_acl_arn  = module.firewall_waf_v2_api[0].arn
  count        = local.is_sandbox ? 0 : 1
  depends_on = [
    aws_api_gateway_stage.ndr_api,
    module.firewall_waf_v2_api[0]
  ]
}
