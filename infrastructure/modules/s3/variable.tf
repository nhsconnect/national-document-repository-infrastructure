variable "bucket_name" {
  description = "The name of the S3 bucket to create."
  type        = string
}

variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "enable_cors_configuration" {
  description = "Whether to enable CORS configuration for the S3 bucket."
  type        = bool
  default     = false
}

variable "enable_bucket_versioning" {
  description = "Whether to enable versioning on the bucket."
  type        = bool
  default     = false
}

variable "cors_rules" {
  description = "List of CORS rules to apply to the S3 bucket."
  default     = []
}
# Tags
variable "environment" {
  description = "Environment label used for tagging (e.g., 'dev', 'prod')."
  type        = string
}

variable "owner" {
  description = "Owner label used for resource tagging."
  type        = string
}

variable "cloudfront_arn" {
  description = "CloudFront distribution ARN association and policy toggles"
  type        = string
  default     = "null"
}

variable "cloudfront_enabled" {
  description = "Enables the correct policy config for CloudFront associated S3 bucket"
  type        = bool
  default     = false
}

variable "access_logs_enabled" {
  description = "Whether to enable S3 access logging for this bucket."
  type        = bool
  default     = false
}

variable "access_logs_bucket_id" {
  type        = string
  description = "Enables access logs on the module's bucket"
}
