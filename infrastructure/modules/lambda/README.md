# Lambda Function with Optional API Gateway Integration Module

This Terraform module provisions an AWS Lambda function with optional API Gateway integration and IAM configuration. It supports both standalone and API-invoked functions, including those used for custom authorizers.

The module is designed to streamline deployment of Lambda code packages, environment variables, IAM roles, concurrency settings, and optional REST API method bindings.

---

## Features

- Lambda function with configurable:
  - Memory, timeout, environment, storage, concurrency
- Optional REST API Gateway integration
- Conditional Lambda permissions for API Gateway invocation
- IAM execution role with default and custom policies
- Outputs for function name, ARNs, and role

---

## Usage

```hcl
module "lambda" {
  source = "./modules/lambda"

  # Required: Unique name for the Lambda function
  name = "my-handler"

  # Required: Entry point in the codebase (e.g., "index.handler")
  handler = "index.handler"

  # Required: ID of the associated API Gateway REST API
  rest_api_id = aws_api_gateway_rest_api.my_api.id

  # Required: Execution ARN of the REST API (used in lambda_permission)
  api_execution_arn = "arn:aws:execute-api:eu-west-2:123456789012:abc123/*"

  # Optional: List of HTTP methods to support on the resource (e.g., ["GET", "POST"])
  http_methods = ["GET"]

  # Optional: Gateway resource ID (used for method attachment)
  resource_id = aws_api_gateway_resource.example.id

  # Optional: Allow Lambda to be invoked by API Gateway
  is_invoked_from_gateway = true

  # Optional: Whether to create the aws_api_gateway_integration resource
  is_gateway_integration_needed = true

  # Optional: Environment variables for the Lambda function
  lambda_environment_variables = {
    STAGE = "prod"
  }

  # Optional: Additional IAM policy ARNs to attach to the role
  iam_role_policy_documents = [
    data.aws_iam_policy_document.custom.json
  ]

  # Optional: Reserved concurrency (e.g., -1 = unlimited, 0 = disabled)
  reserved_concurrent_executions = -1

  # Optional: Function timeout in seconds
  lambda_timeout = 30

  # Optional: Memory size in MB
  memory_size = 512

  # Optional: Ephemeral storage (in MB)
  lambda_ephemeral_storage = 512
}


```

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
