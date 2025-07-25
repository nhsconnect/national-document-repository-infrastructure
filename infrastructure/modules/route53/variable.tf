variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "dns_name" {
  type = string
}

variable "domain" {
  type = string
}

variable "using_arf_hosted_zone" {
  type    = bool
  default = true
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
  description = "Zone Id for api gateway custom domain"
  type        = string
}

locals {
  zone_id = var.using_arf_hosted_zone ? data.aws_route53_zone.ndr_zone[0].zone_id : aws_route53_zone.ndr_zone[0].zone_id
}

output "zone_id" {
  value = local.zone_id
}
