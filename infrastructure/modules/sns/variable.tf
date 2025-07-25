variable "topic_name" {
  description = "Name of the SNS topic."
  type        = string
}

variable "delivery_policy" {
  description = "Attach delivery or IAM policy."
  type        = string
}
variable "enable_fifo" {
  description = "Attach first in first out policy to notification queue."
  type        = bool
  default     = false
}

variable "enable_deduplication" {
  description = "Prevent content based duplication in notification queue."
  type        = bool
  default     = false
}

variable "topic_protocol" {
  description = "The protocol to use for the subscription (e.g., 'sqs', 'lambda')."
  type        = string
}

variable "topic_endpoint" {
  description = "A single endpoint (e.g., SQS queue or Lambda function ARN) to subscribe to the topic."
  type        = any
  default     = null
}


variable "topic_endpoint_list" {
  description = "A list of endpoints (e.g., SQS ARNs) to subscribe to the topic."
  type        = any
  default     = []
}

variable "current_account_id" {
  description = "The AWS account ID where the topic will be created."
  type        = string
}

variable "sns_encryption_key_id" {
  description = "The ARN of the KMS key used for encrypting the SNS topic."
  type        = string
}

variable "sqs_feedback" {
  description = "Map of IAM role ARNs and sample rate for success and failure feedback."
  type        = map(string)
  default     = {}
}

variable "raw_message_delivery" {
  description = "Whether to enable raw message delivery for the SNS subscription."
  type        = bool
  default     = false
}

variable "is_topic_endpoint_list" {
  description = "Whether to use the topic_endpoint_list instead of a single topic_endpoint."
  type        = bool
  default     = false
}
