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

variable "secure_transport_enabled" {
  type    = bool
  default = true
}

variable "presigned_url_ttl" {
  type    = number
  default = 60000
}

# Outputs
output "s3_object_access_policy" {
  value = aws_iam_policy.s3_document_data_policy.arn
}

output "s3_list_object_policy" {
  value = aws_iam_policy.s3_list_object_policy.arn
}

output "bucket_id" {
  value = aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.bucket.arn
}