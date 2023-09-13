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
| [aws_sns_topic.sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.sns_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_delivery_policy"></a> [delivery\_policy](#input\_delivery\_policy) | Attach delivery or IAM policy | `string` | n/a | yes |
| <a name="input_enable_deduplication"></a> [enable\_deduplication](#input\_enable\_deduplication) | Prevent content based duplication in notification queue | `bool` | `false` | no |
| <a name="input_enable_fifo"></a> [enable\_fifo](#input\_enable\_fifo) | Attach first in first out policy to notification queue | `bool` | `false` | no |
| <a name="input_topic_endpoint"></a> [topic\_endpoint](#input\_topic\_endpoint) | n/a | `string` | n/a | yes |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | Name of the SNS topic | `string` | n/a | yes |
| <a name="input_topic_protocol"></a> [topic\_protocol](#input\_topic\_protocol) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | n/a |
