variable "bucket_domain_name" {
  description = "Domain name to assign CloudFront distribution to."
  type        = string
}

variable "bucket_id" {
  description = "Bucket ID to assign CloudFront distribution to."
  type        = string
}

variable "qualifed_arn" {
  description = "Lambda@Edge function association."
  type        = string
}

variable "web_acl_id" {
  description = "Web ACL to associate this CloudFront distribution with."
  type        = string
  default     = ""
}

