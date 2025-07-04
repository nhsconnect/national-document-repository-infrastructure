resource "aws_sqs_queue" "sqs_queue" {
  name                        = "${terraform.workspace}-${var.name}"
  delay_seconds               = var.delay
  visibility_timeout_seconds  = var.max_visibility
  max_message_size            = var.max_size_message
  message_retention_seconds   = var.message_retention
  receive_wait_time_seconds   = var.receive_wait
  sqs_managed_sse_enabled     = var.enable_sse
  fifo_queue                  = var.enable_fifo
  content_based_deduplication = var.enable_deduplication
  kms_master_key_id           = var.kms_master_key_id

  tags = {
    Name        = "${terraform.workspace}-${var.name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_sqs_queue" "queue_deadletter" {
  count                       = var.enable_dlq ? 1 : 0
  name                        = "${terraform.workspace}-deadletter-${var.name}"
  delay_seconds               = var.delay
  visibility_timeout_seconds  = var.dlq_visibility_timeout
  max_message_size            = var.max_size_message
  message_retention_seconds   = var.dlq_message_retention
  receive_wait_time_seconds   = var.receive_wait
  sqs_managed_sse_enabled     = var.enable_sse
  fifo_queue                  = var.enable_fifo
  content_based_deduplication = var.enable_deduplication
  kms_master_key_id           = var.kms_master_key_id

  tags = {
    Name        = "${terraform.workspace}-${var.name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_sqs_queue_redrive_allow_policy" "terraform_queue_redrive_allow_policy" {
  count = var.enable_dlq ? 1 : 0

  queue_url = aws_sqs_queue.queue_deadletter[0].id
  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.sqs_queue.arn]
  })
}

resource "aws_sqs_queue_redrive_policy" "dlq_redrive" {
  count     = var.enable_dlq ? 1 : 0
  queue_url = aws_sqs_queue.sqs_queue.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.queue_deadletter[0].arn
    maxReceiveCount     = var.max_receive_count
  })
}

data "aws_iam_policy_document" "sqs_read_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = concat(
      [aws_sqs_queue.sqs_queue.arn],
      var.enable_dlq ? [aws_sqs_queue.queue_deadletter[0].arn] : []
    )
  }
}

data "aws_iam_policy_document" "sqs_write_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:DeleteMessage"
    ]
    resources = concat(
      [aws_sqs_queue.sqs_queue.arn],
      var.enable_dlq ? [aws_sqs_queue.queue_deadletter[0].arn] : []
    )
  }
}
