<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_archive"></a> [archive](#provider_archive) | n/a     |
| <a name="provider_aws"></a> [aws](#provider_aws)             | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                             | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_api_gateway_integration.lambda_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration)            | resource    |
| [aws_iam_policy.combined_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                       | resource    |
| [aws_iam_role.lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                       | resource    |
| [aws_iam_role_policy_attachment.default_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)        | resource    |
| [aws_iam_role_policy_attachment.lambda_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                        | resource    |
| [aws_lambda_permission.lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                         | resource    |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                   | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                        | data source |
| [aws_iam_policy_document.merged_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                      | data source |

## Inputs

| Name                                                                                                                        | Description                                                                                                                                                   | Type           | Default                                                                                                                                                                | Required |
| --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_api_execution_arn"></a> [api_execution_arn](#input_api_execution_arn)                                        | n/a                                                                                                                                                           | `string`       | n/a                                                                                                                                                                    |   yes    |
| <a name="input_default_policies"></a> [default_policies](#input_default_policies)                                           | n/a                                                                                                                                                           | `list`         | <pre>[<br/> "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",<br/> "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"<br/>]</pre> |    no    |
| <a name="input_handler"></a> [handler](#input_handler)                                                                      | n/a                                                                                                                                                           | `string`       | n/a                                                                                                                                                                    |   yes    |
| <a name="input_http_methods"></a> [http_methods](#input_http_methods)                                                       | n/a                                                                                                                                                           | `list(string)` | `[]`                                                                                                                                                                   |    no    |
| <a name="input_iam_role_policy_documents"></a> [iam_role_policy_documents](#input_iam_role_policy_documents)                | n/a                                                                                                                                                           | `list(string)` | `[]`                                                                                                                                                                   |    no    |
| <a name="input_is_gateway_integration_needed"></a> [is_gateway_integration_needed](#input_is_gateway_integration_needed)    | Indicate whether the lambda need an aws_api_gateway_integration resource block                                                                                | `bool`         | `true`                                                                                                                                                                 |    no    |
| <a name="input_is_invoked_from_gateway"></a> [is_invoked_from_gateway](#input_is_invoked_from_gateway)                      | Indicate whether the lambda is supposed to be invoked by API gateway. Should be true for authoriser lambda.                                                   | `bool`         | `true`                                                                                                                                                                 |    no    |
| <a name="input_lambda_environment_variables"></a> [lambda_environment_variables](#input_lambda_environment_variables)       | n/a                                                                                                                                                           | `map(string)`  | `{}`                                                                                                                                                                   |    no    |
| <a name="input_lambda_ephemeral_storage"></a> [lambda_ephemeral_storage](#input_lambda_ephemeral_storage)                   | n/a                                                                                                                                                           | `number`       | `512`                                                                                                                                                                  |    no    |
| <a name="input_lambda_timeout"></a> [lambda_timeout](#input_lambda_timeout)                                                 | n/a                                                                                                                                                           | `number`       | `30`                                                                                                                                                                   |    no    |
| <a name="input_memory_size"></a> [memory_size](#input_memory_size)                                                          | n/a                                                                                                                                                           | `number`       | `512`                                                                                                                                                                  |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                               | n/a                                                                                                                                                           | `string`       | n/a                                                                                                                                                                    |   yes    |
| <a name="input_reserved_concurrent_executions"></a> [reserved_concurrent_executions](#input_reserved_concurrent_executions) | The number of concurrent execution allowed for lambda. A value of 0 will stop lambda from running, and -1 removes any concurrency limitations. Default to -1. | `number`       | `-1`                                                                                                                                                                   |    no    |
| <a name="input_resource_id"></a> [resource_id](#input_resource_id)                                                          | n/a                                                                                                                                                           | `string`       | `""`                                                                                                                                                                   |    no    |
| <a name="input_rest_api_id"></a> [rest_api_id](#input_rest_api_id)                                                          | n/a                                                                                                                                                           | `string`       | n/a                                                                                                                                                                    |   yes    |

## Outputs

| Name                                                                                                              | Description |
| ----------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_function_name"></a> [function_name](#output_function_name)                                        | n/a         |
| <a name="output_invoke_arn"></a> [invoke_arn](#output_invoke_arn)                                                 | n/a         |
| <a name="output_lambda_arn"></a> [lambda_arn](#output_lambda_arn)                                                 | n/a         |
| <a name="output_lambda_execution_role_arn"></a> [lambda_execution_role_arn](#output_lambda_execution_role_arn)    | n/a         |
| <a name="output_lambda_execution_role_name"></a> [lambda_execution_role_name](#output_lambda_execution_role_name) | n/a         |
| <a name="output_qualified_arn"></a> [qualified_arn](#output_qualified_arn)                                        | n/a         |
| <a name="output_timeout"></a> [timeout](#output_timeout)                                                          | n/a         |

<!-- END_TF_DOCS -->
