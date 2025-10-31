module "cloudfront_firewall_waf_v2" {
  source         = "./modules/firewall_waf_v2"
  cloudfront_acl = true

  environment = var.environment
  owner       = var.owner
  count       = local.is_sandbox ? 0 : 1
  providers   = { aws = aws.us_east_1 }
}

module "cloudfront-distribution-lg" {
  source                        = "./modules/cloudfront"
  bucket_domain_name            = module.ndr-lloyd-george-store.bucket_regional_domain_name
  bucket_id                     = module.ndr-lloyd-george-store.bucket_id
  qualifed_arn                  = module.edge-presign-lambda.qualified_arn
  depends_on                    = [module.edge-presign-lambda.qualified_arn, module.ndr-lloyd-george-store.bucket_id, module.ndr-lloyd-george-store.bucket_domain_name, module.ndr-document-pending-review-store.bucket_id, module.ndr-document-pending-review-store.bucket_domain_name]
  web_acl_id                    = try(module.cloudfront_firewall_waf_v2[0].arn, "")
  has_secondary_bucket          = local.is_production ? false : true
  secondary_bucket_domain_name  = module.ndr-document-pending-review-store.bucket_regional_domain_name
  secondary_bucket_id           = module.ndr-document-pending-review-store.bucket_id
  secondary_bucket_path_pattern = "/review/*"
  log_bucket_id                 = local.access_logs_bucket_id
}