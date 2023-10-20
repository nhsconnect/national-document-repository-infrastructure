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

variable "max_message" {
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

output "endpoint" {
  value       = aws_sqs_queue.sqs_queue.arn
  description = "Same as sqs queue arn. For use when setting the queue as endpoint of sns topic"
}


output "sqs_arn" {
  value = aws_sqs_queue.sqs_queue.arn
}


output "sqs_policy" {
  value       = aws_iam_policy.sqs_queue_policy.arn
  description = "Arn for the iam policy for accessing this queue"
}

output "sqs_url" {
  value = aws_sqs_queue.sqs_queue.url
}