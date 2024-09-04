variable "bucket_name" {
  description = "the name of the bucket"
  type        = string
}



variable "force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}

variable "enable_cors_configuration" {
  type    = bool
  default = false
}

variable "enable_bucket_versioning" {
  type    = bool
  default = false
}

variable "cors_rules" {
  default = []
}
# Tags
variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "cloudfront_arn" {
  type        = string
  default     = "null"
  description = "Cloudfront Distribution ARN association and policy toggles"
}

variable "cloudfront_enabled" {
  type        = bool
  default     = false
  description = "Enables the correct policy config for cloudfront s3"
}