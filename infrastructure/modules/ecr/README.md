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
| [aws_ecr_lifecycle_policy.ndr_ecr_lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy)    | resource |
| [aws_ecr_repository.ndr-ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository)                                 | resource |
| [aws_ecr_repository_policy.ndr_ecr_repository_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name                                                                                    | Description         | Type     | Default | Required |
| --------------------------------------------------------------------------------------- | ------------------- | -------- | ------- | :------: |
| <a name="input_app_name"></a> [app_name](#input_app_name)                               | the name of the app | `string` | n/a     |   yes    |
| <a name="input_current_account_id"></a> [current_account_id](#input_current_account_id) | n/a                 | `string` | n/a     |   yes    |
| <a name="input_environment"></a> [environment](#input_environment)                      | n/a                 | `string` | n/a     |   yes    |
| <a name="input_owner"></a> [owner](#input_owner)                                        | n/a                 | `string` | n/a     |   yes    |

## Outputs

| Name                                                                                      | Description |
| ----------------------------------------------------------------------------------------- | ----------- |
| <a name="output_ecr_repository_url"></a> [ecr_repository_url](#output_ecr_repository_url) | n/a         |

<!-- END_TF_DOCS -->
