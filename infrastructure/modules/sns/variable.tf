variable "topic_name" {
  type        = string
  description = "Name of the SNS topic"
}

variable "delivery_policy" {
  type        = string
  description = "Attach delivery or IAM policy"
}
variable "enable_fifo" {
  type        = bool
  default     = false
  description = "Attach first in first out policy to notification queue"
}

variable "enable_deduplication" {
  type        = bool
  default     = false
  description = "Prevent content based duplication in notification queue"
}

variable "topic_protocol" {
  type = string
}

variable "topic_endpoint" {
  type    = any
  default = null
}

variable "topic_endpoint_list" {
  type    = any
  default = []
}

variable "sns_encryption_key_id" {
  type = string
}

variable "sqs_feedback" {
  description = "Map of IAM role ARNs and sample rate for success and failure feedback"
  type        = map(string)
  default     = {}
}

variable "raw_message_delivery" {
  default = false
}

variable "is_topic_endpoint_list" {
  default = false
  type    = bool
}
