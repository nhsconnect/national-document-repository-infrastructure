variable "environment" {
  description = "Environment tag used for context and identification (e.g., 'dev', 'prod')."
  type        = string
}

variable "owner" {
  description = "Owner tag used for resource tagging and identification."
  type        = string
}

variable "dns_name" {
  description = "The target DNS name for the record, typically the Fargate or Load Balancer endpoint."
  type        = string
}

variable "domain" {
  description = "The root domain name used to find or create the Route53 hosted zone."
  type        = string
}

variable "certificate_domain" {
  description = "The domain name used for locating the TLS certificate (e.g., '*.example.com')."
  type        = string
}

variable "using_arf_hosted_zone" {
  description = "Whether to use a shared hosted zone for ARF or multi-module deployments."
  type        = bool
  default     = true
}

variable "api_gateway_subdomain_name" {
  description = "Subdomain name for api gateway custom domain. Example: api-dev"
  type        = string
}

variable "api_gateway_full_domain_name" {
  description = "Full domain name for api gateway custom domain. Example: api-dev.access-request-fulfilment.patient-deductions.nhs.uk"
  type        = string
}

variable "api_gateway_zone_id" {
  description = "The Route53 zone ID associated with the API Gateway custom domain."
  type        = string
}

locals {
  zone_id = var.using_arf_hosted_zone ? data.aws_route53_zone.ndr_zone[0].zone_id : aws_route53_zone.ndr_zone[0].zone_id
}

output "zone_id" {
  value = local.zone_id
}
