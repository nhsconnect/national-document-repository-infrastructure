variable "bucket_domain_name" {
  type        = string
  description = "Domain name to assign CloudFront distribution to"
}

variable "bucket_id" {
  type        = string
  description = "Bucket ID to assign CloudFront distribution to"
}

variable "qualifed_arn" {
  type        = string
  description = "Lambda@Edge function association"
}

variable "forwarding_policy" {
  type        = string
  default     = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" #Managed-AllViewer Policy
  description = "Manged or custom policy for CloudFront distribution caching and forwarding"
}
