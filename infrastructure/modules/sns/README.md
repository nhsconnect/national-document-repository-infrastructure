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

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                     | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_sns_topic.sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic)                                         | resource |
| [aws_sns_topic_subscription.sns_subscription_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription)   | resource |
| [aws_sns_topic_subscription.sns_subscription_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name                                                                                                | Description                                                           | Type          | Default | Required |
| --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ------------- | ------- | :------: |
| <a name="input_current_account_id"></a> [current_account_id](#input_current_account_id)             | n/a                                                                   | `string`      | n/a     |   yes    |
| <a name="input_delivery_policy"></a> [delivery_policy](#input_delivery_policy)                      | Attach delivery or IAM policy                                         | `string`      | n/a     |   yes    |
| <a name="input_enable_deduplication"></a> [enable_deduplication](#input_enable_deduplication)       | Prevent content based duplication in notification queue               | `bool`        | `false` |    no    |
| <a name="input_enable_fifo"></a> [enable_fifo](#input_enable_fifo)                                  | Attach first in first out policy to notification queue                | `bool`        | `false` |    no    |
| <a name="input_is_topic_endpoint_list"></a> [is_topic_endpoint_list](#input_is_topic_endpoint_list) | n/a                                                                   | `bool`        | `false` |    no    |
| <a name="input_raw_message_delivery"></a> [raw_message_delivery](#input_raw_message_delivery)       | n/a                                                                   | `bool`        | `false` |    no    |
| <a name="input_sns_encryption_key_id"></a> [sns_encryption_key_id](#input_sns_encryption_key_id)    | n/a                                                                   | `string`      | n/a     |   yes    |
| <a name="input_sqs_feedback"></a> [sqs_feedback](#input_sqs_feedback)                               | Map of IAM role ARNs and sample rate for success and failure feedback | `map(string)` | `{}`    |    no    |
| <a name="input_topic_endpoint"></a> [topic_endpoint](#input_topic_endpoint)                         | n/a                                                                   | `any`         | `null`  |    no    |
| <a name="input_topic_endpoint_list"></a> [topic_endpoint_list](#input_topic_endpoint_list)          | n/a                                                                   | `any`         | `[]`    |    no    |
| <a name="input_topic_name"></a> [topic_name](#input_topic_name)                                     | Name of the SNS topic                                                 | `string`      | n/a     |   yes    |
| <a name="input_topic_protocol"></a> [topic_protocol](#input_topic_protocol)                         | n/a                                                                   | `string`      | n/a     |   yes    |

## Outputs

| Name                                         | Description |
| -------------------------------------------- | ----------- |
| <a name="output_arn"></a> [arn](#output_arn) | n/a         |

<!-- END_TF_DOCS -->
