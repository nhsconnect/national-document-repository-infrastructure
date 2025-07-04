variable "name" {
  type = string
}

variable "delay" {
  description = "The time in seconds that the delivery of all messages in the queue will be delayed"
  type        = number
  default     = 0
}

variable "max_visibility" {
  description = "Time in seconds during which Amazon SQS prevents all consumers from receiving and processing the message"
  type        = number
  default     = 30
}

variable "max_size_message" {
  description = "Max message size in bytes before sqs rejects the message"
  type        = number
  default     = 2048
}

variable "message_retention" {
  description = "Number of seconds sqs keeps a message"
  type        = number
  default     = 86400
}

variable "receive_wait" {
  description = "Number of seconds sqs will wait for a message when ReceiveMessage is received"
  type        = number
  default     = 2
}

variable "enable_sse" {
  description = "Enable server-side encryption (SSE) of message content with SQS-owned encryption keys, requires kms resource for queue"
  type        = bool
  default     = true
}

variable "enable_deduplication" {
  type        = bool
  default     = false
  description = "Prevent content based duplication in queue"
}

variable "enable_fifo" {
  type        = bool
  default     = false
  description = "Attach first in first out policy to sqs"
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK"
  type        = string
  default     = null
}

variable "max_receive_count" {
  type    = number
  default = 1
}

variable "enable_dlq" {
  type    = bool
  default = false
}

variable "dlq_visibility_timeout" {
  type    = number
  default = 0
}

variable "dlq_message_retention" {
  description = "Number of seconds the DLQ retains a message"
  type        = number
  default     = 1209600
}

# Tags
variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

output "endpoint" {
  value       = aws_sqs_queue.sqs_queue.arn
  description = "Same as sqs queue arn. For use when setting the queue as endpoint of sns topic"
}

output "sqs_arn" {
  value = aws_sqs_queue.sqs_queue.arn
}

output "sqs_id" {
  value = aws_sqs_queue.sqs_queue.id
}

output "sqs_url" {
  value = aws_sqs_queue.sqs_queue.url
}

output "sqs_read_policy_document" {
  value = data.aws_iam_policy_document.sqs_read_policy.json
}

output "sqs_write_policy_document" {
  value = data.aws_iam_policy_document.sqs_write_policy.json
}
output "dlq_name" {
  value = var.enable_dlq ? aws_sqs_queue.queue_deadletter[0].name : null
}