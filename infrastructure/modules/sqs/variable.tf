variable "name" {
  description = "Name of the SQS queue."
  type        = string
}

variable "delay" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed."
  type        = number
  default     = 0
}

variable "max_visibility" {
  description = "Time in seconds during which Amazon SQS prevents all consumers from receiving and processing the message."
  type        = number
  default     = 30
}

variable "max_size_message" {
  description = "Max message size in bytes before sqs rejects the message."
  type        = number
  default     = 2048
}

variable "message_retention" {
  description = "Number of seconds sqs keeps a message."
  type        = number
  default     = 86400
}

variable "receive_wait" {
  description = "Number of seconds sqs will wait for a message when ReceiveMessage is received."
  type        = number
  default     = 2
}

variable "enable_sse" {
  description = "Enable server-side encryption (SSE) of message content with SQS-owned encryption keys, requires kms resource for queue."
  type        = bool
  default     = true
}

variable "enable_deduplication" {
  description = "Prevent content based duplication in queue."
  type        = bool
  default     = false
}

variable "enable_fifo" {
  description = "Attach 'first in first' out policy to SQS queue."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK."
  type        = string
  default     = null
}

variable "max_receive_count" {
  description = "Maximum number of receives before messages are moved to the dead-letter queue."
  type        = number
  default     = 1
}

variable "enable_dlq" {
  description = "Whether to enable a dead-letter queue (DLQ) for the main queue."
  type        = bool
  default     = false
}

variable "dlq_visibility_timeout" {
  description = "Visibility timeout for messages in the dead-letter queue."
  type        = number
  default     = 0
}

variable "dlq_message_retention" {
  description = "Number of seconds the DLQ retains a message."
  type        = number
  default     = 1209600
}

# Tags
variable "environment" {
  description = "Environment tag for the resource (e.g., 'dev', 'prod')."
  type        = string
}

variable "owner" {
  description = "Owner tag used for identifying resource ownership."
  type        = string
}