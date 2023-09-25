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
  type = string
}
