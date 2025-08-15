output "endpoint" {
  description = "The SQS queue ARN e.g. for use when setting the queue as the endpoint of an SNS topic."
  value       = aws_sqs_queue.sqs_queue.arn
}

output "sqs_arn" {
  description = "Amazon Resource Name (ARN) of the primary SQS queue."
  value       = aws_sqs_queue.sqs_queue.arn
}

output "sqs_id" {
  description = "ID of the main SQS queue."
  value       = aws_sqs_queue.sqs_queue.id
}

output "sqs_url" {
  description = "URL of the SQS queue for use with API clients or AWS SDKs."
  value       = aws_sqs_queue.sqs_queue.url
}

output "sqs_read_policy_document" {
  description = "IAM policy document granting read access to the SQS queue."
  value       = data.aws_iam_policy_document.sqs_read_policy.json
}

output "sqs_write_policy_document" {
  description = "IAM policy document granting write access to the SQS queue."
  value       = data.aws_iam_policy_document.sqs_write_policy.json
}

output "dlq_name" {
  description = "Name of the dead-letter queue (DLQ), if created."
  value       = var.enable_dlq ? aws_sqs_queue.queue_deadletter[0].name : null
}

output "queue_name" {
  description = "Name of the queue"
  value       = aws_sqs_queue.sqs_queue.name
}
