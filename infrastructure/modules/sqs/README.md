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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_sqs_queue.queue_deadletter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.sqs_queue](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_redrive_allow_policy.terraform_queue_redrive_allow_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_allow_policy) | resource |
| [aws_sqs_queue_redrive_policy.dlq_redrive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_policy) | resource |
| [aws_iam_policy_document.sqs_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.sqs_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delay"></a> [delay](#input\_delay) | The time in seconds that the delivery of all messages in the queue will be delayed. | `number` | `0` | no |
| <a name="input_dlq_message_retention"></a> [dlq\_message\_retention](#input\_dlq\_message\_retention) | Number of seconds the DLQ retains a message. | `number` | `1209600` | no |
| <a name="input_dlq_visibility_timeout"></a> [dlq\_visibility\_timeout](#input\_dlq\_visibility\_timeout) | Visibility timeout for messages in the dead-letter queue. | `number` | `0` | no |
| <a name="input_enable_deduplication"></a> [enable\_deduplication](#input\_enable\_deduplication) | Prevent content based duplication in queue. | `bool` | `false` | no |
| <a name="input_enable_dlq"></a> [enable\_dlq](#input\_enable\_dlq) | Whether to enable a dead-letter queue (DLQ) for the main queue. | `bool` | `false` | no |
| <a name="input_enable_fifo"></a> [enable\_fifo](#input\_enable\_fifo) | Attach 'first in first' out policy to SQS queue. | `bool` | `false` | no |
| <a name="input_enable_sse"></a> [enable\_sse](#input\_enable\_sse) | Enable server-side encryption (SSE) of message content with SQS-owned encryption keys, requires kms resource for queue. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag for the resource (e.g., 'dev', 'prod'). | `string` | n/a | yes |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | The ID of an AWS-managed customer master key (CMK) for Amazon SQS or a custom CMK. | `string` | `null` | no |
| <a name="input_max_receive_count"></a> [max\_receive\_count](#input\_max\_receive\_count) | Maximum number of receives before messages are moved to the dead-letter queue. | `number` | `1` | no |
| <a name="input_max_size_message"></a> [max\_size\_message](#input\_max\_size\_message) | Max message size in bytes before sqs rejects the message. | `number` | `2048` | no |
| <a name="input_max_visibility"></a> [max\_visibility](#input\_max\_visibility) | Time in seconds during which Amazon SQS prevents all consumers from receiving and processing the message. | `number` | `30` | no |
| <a name="input_message_retention"></a> [message\_retention](#input\_message\_retention) | Number of seconds sqs keeps a message. | `number` | `86400` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the SQS queue. | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner tag used for identifying resource ownership. | `string` | n/a | yes |
| <a name="input_receive_wait"></a> [receive\_wait](#input\_receive\_wait) | Number of seconds sqs will wait for a message when ReceiveMessage is received. | `number` | `2` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dlq_name"></a> [dlq\_name](#output\_dlq\_name) | Name of the dead-letter queue (DLQ), if created. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The SQS queue ARN e.g. for use when setting the queue as the endpoint of an SNS topic. |
| <a name="output_sqs_arn"></a> [sqs\_arn](#output\_sqs\_arn) | Amazon Resource Name (ARN) of the primary SQS queue. |
| <a name="output_sqs_id"></a> [sqs\_id](#output\_sqs\_id) | ID of the main SQS queue. |
| <a name="output_sqs_read_policy_document"></a> [sqs\_read\_policy\_document](#output\_sqs\_read\_policy\_document) | IAM policy document granting read access to the SQS queue. |
| <a name="output_sqs_url"></a> [sqs\_url](#output\_sqs\_url) | URL of the SQS queue for use with API clients or AWS SDKs. |
| <a name="output_sqs_write_policy_document"></a> [sqs\_write\_policy\_document](#output\_sqs\_write\_policy\_document) | IAM policy document granting write access to the SQS queue. |
<!-- END_TF_DOCS -->
