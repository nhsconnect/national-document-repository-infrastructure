# Lambda Proxy for S3 Access Module

This Terraform module provisions an AWS Lambda function designed to act as a proxy for accessing an S3 bucket, typically for use with API Gateway or direct client calls. It sets up the function, IAM role, and execution policy for secure access and control.

The module is ideal for creating tightly-scoped, account-specific Lambda-based API endpoints that interact with S3 or DynamoDB behind the scenes.

---

## Features

- Lambda function with:
  - Configurable timeout, memory, and ephemeral storage
  - Reserved concurrency support
- IAM role with support for user-supplied inline policies
- Outputs function name and ARNs for integration

---

## Usage

```hcl
module "s3_proxy_lambda" {
  source = "./modules/lambda-proxy"

  # Required: Unique name for the Lambda function
  name = "s3-proxy"

  # Required: Handler function in the code package (e.g., "index.handler")
  handler = "index.handler"

  # Required: ID of the current AWS account
  current_account_id = "123456789012"

  # Required: Name of the target S3 bucket
  bucket_name = "my-app-assets"

  # Required: Name of the associated DynamoDB table (if applicable)
  table_name = "my-tracking-table"

  # Required: List of IAM policy ARNs or documents to attach to the role
  iam_role_policies = [
    data.aws_iam_policy_document.lambda_policy.json
  ]

  # Optional: Memory allocation in MB
  memory_size = 128

  # Optional: Function timeout in seconds
  lambda_timeout = 30

  # Optional: Ephemeral storage in MB
  lambda_ephemeral_storage = 512

  # Optional: Reserved concurrency (-1 = unlimited, 0 = disabled)
  reserved_concurrent_executions = -1
}


```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                   | Version |
| ------------------------------------------------------ | ------- |
| <a name="requirement_aws"></a> [aws](#requirement_aws) | ~> 5.0  |

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_archive"></a> [archive](#provider_archive) | n/a     |
| <a name="provider_aws"></a> [aws](#provider_aws)             | ~> 5.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                             | Type        |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_role.lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                            | resource    |
| [aws_iam_role_policy.lambda_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy)                            | resource    |
| [aws_iam_role_policy_attachment.lambda_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                        | resource    |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                   | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                        | data source |
| [aws_iam_policy_document.lambda_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                      | data source |

## Inputs

| Name                                                                                                                        | Description                                                                                                                                                   | Type           | Default | Required |
| --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_bucket_name"></a> [bucket_name](#input_bucket_name)                                                          | The name of the bucket to proxy                                                                                                                               | `string`       | n/a     |   yes    |
| <a name="input_current_account_id"></a> [current_account_id](#input_current_account_id)                                     | AWS Account ID                                                                                                                                                | `string`       | n/a     |   yes    |
| <a name="input_handler"></a> [handler](#input_handler)                                                                      | n/a                                                                                                                                                           | `string`       | n/a     |   yes    |
| <a name="input_iam_role_policies"></a> [iam_role_policies](#input_iam_role_policies)                                        | n/a                                                                                                                                                           | `list(string)` | n/a     |   yes    |
| <a name="input_lambda_ephemeral_storage"></a> [lambda_ephemeral_storage](#input_lambda_ephemeral_storage)                   | n/a                                                                                                                                                           | `number`       | `512`   |    no    |
| <a name="input_lambda_timeout"></a> [lambda_timeout](#input_lambda_timeout)                                                 | n/a                                                                                                                                                           | `number`       | `30`    |    no    |
| <a name="input_memory_size"></a> [memory_size](#input_memory_size)                                                          | n/a                                                                                                                                                           | `number`       | `128`   |    no    |
| <a name="input_name"></a> [name](#input_name)                                                                               | n/a                                                                                                                                                           | `string`       | n/a     |   yes    |
| <a name="input_reserved_concurrent_executions"></a> [reserved_concurrent_executions](#input_reserved_concurrent_executions) | The number of concurrent execution allowed for lambda. A value of 0 will stop lambda from running, and -1 removes any concurrency limitations. Default to -1. | `number`       | `-1`    |    no    |
| <a name="input_table_name"></a> [table_name](#input_table_name)                                                             | The name of the bucket                                                                                                                                        | `string`       | n/a     |   yes    |

## Outputs

| Name                                                                       | Description |
| -------------------------------------------------------------------------- | ----------- |
| <a name="output_function_name"></a> [function_name](#output_function_name) | n/a         |
| <a name="output_lambda_arn"></a> [lambda_arn](#output_lambda_arn)          | n/a         |
| <a name="output_qualified_arn"></a> [qualified_arn](#output_qualified_arn) | n/a         |
| <a name="output_timeout"></a> [timeout](#output_timeout)                   | n/a         |

<!-- END_TF_DOCS -->
