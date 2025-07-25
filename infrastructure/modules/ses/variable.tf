variable "domain_prefix" {
  description = "The subdomain or prefix used to construct the full SES identity domain."
  type        = string
}

variable "domain" {
  description = "The root domain name to be registered with SES and used for verification."
  type        = string
}

variable "zone_id" {
  description = "The Route53 hosted zone ID where DNS verification records will be created."
  type        = string
}

variable "enable" {
  description = "Whether to enable the creation of SES identity, DKIM, and DNS records."
  type        = bool
}
