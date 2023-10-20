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

variable "certificate_domain" {
  type = string
}

variable "using_arf_hosted_zone" {
  type    = bool
  default = true
}
