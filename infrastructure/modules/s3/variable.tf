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

variable "origin" {
  type = string
}

# Tags

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

output "s3_object_access_policy" {
  value = aws_iam_policy.s3_document_data_policy.arn
}