## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue.sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.sqs_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_iam_policy_document.sqs_queue_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delay"></a> [delay](#input\_delay) | The time in seconds that the delivery of all messages in the queue will be delayed | `number` | `0` | no |
| <a name="input_enable_deduplication"></a> [enable\_deduplication](#input\_enable\_deduplication) | Prevent content based duplication in queue | `bool` | `false` | no |
| <a name="input_enable_fifo"></a> [enable\_fifo](#input\_enable\_fifo) | Attach first in first out policy to sqs | `bool` | `false` | no |
| <a name="input_enable_sse"></a> [enable\_sse](#input\_enable\_sse) | Enable server-side encryption (SSE) of message content with SQS-owned encryption keys, requires kms resource for queue | `bool` | `true` | no |
| <a name="input_max_message"></a> [max\_message](#input\_max\_message) | Max message size in bytes before sqs rejects the message | `number` | `2048` | no |
| <a name="input_max_visibility"></a> [max\_visibility](#input\_max\_visibility) | Time in seconds during which Amazon SQS prevents all consumers from receiving and processing the message | `number` | `30` | no |
| <a name="input_message_retention"></a> [message\_retention](#input\_message\_retention) | Number of seconds sqs keeps a message | `number` | `86400` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_receive_wait"></a> [receive\_wait](#input\_receive\_wait) | Number of seconds sqs will wait for a message when ReceiveMessage is received | `number` | `2` | no |

## Outputs

No outputs.
