resource "aws_sqs_queue" "sqs_queue" {
  name                        = "${terraform.workspace}-${var.name}"
  delay_seconds               = var.delay
  visibility_timeout_seconds  = var.max_visibility
  max_message_size            = var.max_message
  message_retention_seconds   = var.message_retention
  receive_wait_time_seconds   = var.receive_wait
  sqs_managed_sse_enabled     = var.enable_sse
  fifo_queue                  = var.enable_fifo
  content_based_deduplication = var.enable_deduplication
}

resource "aws_iam_policy" "sqs_queue_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      "Sid"    = "shsqsstatement",
      "Effect" = "Allow",
      "Action" = [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource" = [
        aws_sqs_queue.sqs_queue.arn
      ]
  }] })
}