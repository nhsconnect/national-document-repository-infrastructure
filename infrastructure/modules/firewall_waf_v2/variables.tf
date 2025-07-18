variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "cloudfront_acl" {
  type = bool
}

variable "api" {
  type        = bool
  description = "True if using the firewall for an api - removes AWSBotControl"
  default     = false
}

