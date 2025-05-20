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

| Name                                                                                                                                                                                  | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_sqs_queue.queue_deadletter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)                                                               | resource    |
| [aws_sqs_queue.sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue)                                                                      | resource    |
| [aws_sqs_queue_redrive_allow_policy.terraform_queue_redrive_allow_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_allow_policy) | resource    |
| [aws_sqs_queue_redrive_policy.dlq_redrive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_policy)                                      | resource    |
| [aws_iam_policy_document.sqs_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                         | data source |
| [aws_iam_policy_document.sqs_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                        | data source |

## Inputs

| Name                                                                                                | Description                                                                                                            | Type     | Default | Required |
| --------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_delay"></a> [delay](#input_delay)                                                    | The time in seconds that the delivery of all messages in the queue will be delayed                                     | `number` | `0`     |    no    |
| <a name="input_dlq_visibility_timeout"></a> [dlq_visibility_timeout](#input_dlq_visibility_timeout) | n/a                                                                                                                    | `number` | `0`     |    no    |
| <a name="input_enable_deduplication"></a> [enable_deduplication](#input_enable_deduplication)       | Prevent content based duplication in queue                                                                             | `bool`   | `false` |    no    |
| <a name="input_enable_dlq"></a> [enable_dlq](#input_enable_dlq)                                     | n/a                                                                                                                    | `bool`   | `false` |    no    |
| <a name="input_enable_fifo"></a> [enable_fifo](#input_enable_fifo)                                  | Attach first in first out policy to sqs                                                                                | `bool`   | `false` |    no    |
| <a name="input_enable_sse"></a> [enable_sse](#input_enable_sse)                                     | Enable server-side encryption (SSE) of message content with SQS-owned encryption keys, requires kms resource for queue | `bool`   | `true`  |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                  | Tags                                                                                                                   | `string` | n/a     |   yes    |
| <a name="input_kms_master_key_id"></a> [kms_master_key_id](#input_kms_master_key_id)                | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK                                      | `string` | `null`  |    no    |
| <a name="input_max_receive_count"></a> [max_receive_count](#input_max_receive_count)                | n/a                                                                                                                    | `number` | `1`     |    no    |
| <a name="input_max_size_message"></a> [max_size_message](#input_max_size_message)                   | Max message size in bytes before sqs rejects the message                                                               | `number` | `2048`  |    no    |
| <a name="input_max_visibility"></a> [max_visibility](#input_max_visibility)                         | Time in seconds during which Amazon SQS prevents all consumers from receiving and processing the message               | `number` | `30`    |    no    |
| <a name="input_message_retention"></a> [message_retention](#input_message_retention)                | Number of seconds sqs keeps a message                                                                                  | `number` | `86400` |    no    |
| <a name="input_name"></a> [name](#input_name)                                                       | n/a                                                                                                                    | `string` | n/a     |   yes    |
| <a name="input_owner"></a> [owner](#input_owner)                                                    | n/a                                                                                                                    | `string` | n/a     |   yes    |
| <a name="input_receive_wait"></a> [receive_wait](#input_receive_wait)                               | Number of seconds sqs will wait for a message when ReceiveMessage is received                                          | `number` | `2`     |    no    |

## Outputs

| Name                                                                                                           | Description                                                                    |
| -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| <a name="output_dlq_name"></a> [dlq_name](#output_dlq_name)                                                    | n/a                                                                            |
| <a name="output_endpoint"></a> [endpoint](#output_endpoint)                                                    | Same as sqs queue arn. For use when setting the queue as endpoint of sns topic |
| <a name="output_sqs_arn"></a> [sqs_arn](#output_sqs_arn)                                                       | n/a                                                                            |
| <a name="output_sqs_id"></a> [sqs_id](#output_sqs_id)                                                          | n/a                                                                            |
| <a name="output_sqs_read_policy_document"></a> [sqs_read_policy_document](#output_sqs_read_policy_document)    | n/a                                                                            |
| <a name="output_sqs_url"></a> [sqs_url](#output_sqs_url)                                                       | n/a                                                                            |
| <a name="output_sqs_write_policy_document"></a> [sqs_write_policy_document](#output_sqs_write_policy_document) | n/a                                                                            |

<!-- END_TF_DOCS -->
