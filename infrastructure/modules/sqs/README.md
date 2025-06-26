# SQS Queue Module with Optional DLQ, Encryption, and FIFO Support

## Features

- SQS queue with:
  - Configurable visibility timeout, message retention, and wait time
  - Optional delay for message delivery
  - Max message size control
- Optional dead-letter queue (DLQ) setup with redrive policies
- Support for FIFO and deduplication
- SSE encryption using SQS-managed or customer-managed KMS keys
- IAM read/write policy documents
- Tagged with environment and owner

---

## Usage

```hcl
module "sqs_queue" {
  source = "./modules/sqs"

  # Required
  name        = "order-processing-queue"
  environment = "prod"
  owner       = "platform"

  # Optional: Enable FIFO behavior
  enable_fifo          = true
  enable_deduplication = true

  # Optional: Retention and size settings
  message_retention = 86400
  max_size_message  = 2048
  delay             = 0
  receive_wait      = 2
  max_visibility    = 30

  # Optional: Enable server-side encryption
  enable_sse        = true
  kms_master_key_id = "alias/aws/sqs"

  # Optional: Dead-letter queue configuration
  enable_dlq             = true
  max_receive_count      = 5
  dlq_visibility_timeout = 60
}


```

<!-- BEGIN_TF_DOCS -->                                                                         |

<!-- END_TF_DOCS -->
