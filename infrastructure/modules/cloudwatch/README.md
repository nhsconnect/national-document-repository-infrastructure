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

| Name                                                                                                                                                  | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudwatch_log_group.ndr_cloudwatch_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_stream.log_stream](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_stream)             | resource |

## Inputs

| Name                                                                                                         | Description                       | Type     | Default | Required |
| ------------------------------------------------------------------------------------------------------------ | --------------------------------- | -------- | ------- | :------: |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch_log_group_name](#input_cloudwatch_log_group_name) | Name of the Cloudwatch log group  | `string` | `null`  |    no    |
| <a name="input_cloudwatch_log_steam_name"></a> [cloudwatch_log_steam_name](#input_cloudwatch_log_steam_name) | Name of the Cloudwatch log stream | `string` | `null`  |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                           | n/a                               | `string` | n/a     |   yes    |
| <a name="input_owner"></a> [owner](#input_owner)                                                             | n/a                               | `string` | n/a     |   yes    |
| <a name="input_retention_in_days"></a> [retention_in_days](#input_retention_in_days)                         | Name of the Cloudwatch log group  | `number` | `3`     |    no    |

## Outputs

| Name                                                                                                           | Description |
| -------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch_log_group_arn](#output_cloudwatch_log_group_arn)    | n/a         |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch_log_group_name](#output_cloudwatch_log_group_name) | n/a         |

<!-- END_TF_DOCS -->
