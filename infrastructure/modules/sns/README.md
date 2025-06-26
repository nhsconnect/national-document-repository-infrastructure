# SNS Topic Module with Optional Subscriptions and Encryption

## Features

- Creates an SNS topic (standard or FIFO)
- Enables optional message deduplication and raw delivery
- KMS encryption via provided key ID
- Supports:
  - Single subscription (e.g., Lambda or SQS)
  - List of subscriptions via `topic_endpoint_list`
- Configurable delivery policy
- Optional SQS feedback role mapping

---

## Usage

```hcl
module "sns_topic" {
  source = "./modules/sns"

  # Required: Name of the topic to create
  topic_name = "alerts-topic"

  # Required: AWS account ID
  current_account_id = "123456789012"

  # Required: Protocol to use for the subscription
  topic_protocol = "sqs"

  # Required: ARN of the KMS key for encryption
  sns_encryption_key_id = "arn:aws:kms:eu-west-2:123456789012:key/abc123"

  # Required: JSON-encoded delivery policy
  delivery_policy = jsonencode({
    healthyRetryPolicy = {
      minDelayTarget = 20,
      maxDelayTarget = 20,
      numRetries     = 3,
      numMaxDelayRetries = 0
    }
  })

  # Optional: Enable FIFO topic and deduplication
  enable_fifo            = false
  enable_deduplication   = false

  # Optional: Enable raw message delivery
  raw_message_delivery = true

  # Optional: Use a single endpoint
  topic_endpoint = "arn:aws:sqs:eu-west-2:123456789012:target-queue"

  # Optional: Provide a list of endpoints instead
  topic_endpoint_list = [
    "arn:aws:sqs:eu-west-2:123456789012:queue-1",
    "arn:aws:sqs:eu-west-2:123456789012:queue-2"
  ]

  # Optional: Flag to use endpoint list rather than single value
  is_topic_endpoint_list = true

  # Optional: SQS feedback sample rates and IAM roles
  sqs_feedback = {
    "arn:aws:iam::123456789012:role/success" = "100"
    "arn:aws:iam::123456789012:role/failure" = "100"
  }
}


```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
