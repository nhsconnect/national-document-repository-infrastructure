
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

data "aws_iam_policy_document" "sqs_queue_policy" {
  statement {
    sid    = "shsqsstatement"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:SendMessage",
      "sqs:ReceiveMessage"
    ]
    resources = [
      aws_sqs_queue.sqs_queue.arn
    ]
  }
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  queue_url = aws_sqs_queue.sqs_queue.id
  policy    = data.aws_iam_policy_document.sqs_queue_policy.json
}