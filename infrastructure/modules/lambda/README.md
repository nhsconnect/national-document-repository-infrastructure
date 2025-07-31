# Lambda Function with Optional API Gateway Integration Module

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

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_integration.lambda_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_iam_policy.combined_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.default_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.lambda_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.merged_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_execution_arn"></a> [api\_execution\_arn](#input\_api\_execution\_arn) | Execution ARN of the API Gateway used for granting invoke permissions. | `string` | `""` | no |
| <a name="input_default_policies"></a> [default\_policies](#input\_default\_policies) | List of default IAM policy ARNs to attach to the Lambda execution role. | `list(string)` | <pre>[<br/>  "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",<br/>  "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"<br/>]</pre> | no |
| <a name="input_handler"></a> [handler](#input\_handler) | Function entry point in the codebase (e.g., 'index.handler'). | `string` | n/a | yes |
| <a name="input_http_methods"></a> [http\_methods](#input\_http\_methods) | List of HTTP methods to integrate with the Lambda function. | `list(string)` | `[]` | no |
| <a name="input_iam_role_policy_documents"></a> [iam\_role\_policy\_documents](#input\_iam\_role\_policy\_documents) | List of IAM policy document ARNs to attach to the Lambda execution role. | `list(string)` | `[]` | no |
| <a name="input_is_gateway_integration_needed"></a> [is\_gateway\_integration\_needed](#input\_is\_gateway\_integration\_needed) | Indicate whether the lambda need an aws\_api\_gateway\_integration resource block | `bool` | `true` | no |
| <a name="input_is_invoked_from_gateway"></a> [is\_invoked\_from\_gateway](#input\_is\_invoked\_from\_gateway) | Indicate whether the lambda is supposed to be invoked by API gateway. Should be true for authoriser lambda. | `bool` | `true` | no |
| <a name="input_lambda_environment_variables"></a> [lambda\_environment\_variables](#input\_lambda\_environment\_variables) | Map of environment variables to set in the Lambda function. | `map(string)` | `{}` | no |
| <a name="input_lambda_ephemeral_storage"></a> [lambda\_ephemeral\_storage](#input\_lambda\_ephemeral\_storage) | Amount of ephemeral storage (in MB) to allocate to the Lambda function. | `number` | `512` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Function timeout in seconds. | `number` | `30` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory to allocate to the Lambda function (in MB). | `number` | `512` | no |
| <a name="input_name"></a> [name](#input\_name) | Unique name for the Lambda function. | `string` | n/a | yes |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | The number of concurrent execution allowed for lambda. A value of 0 will stop lambda from running, and -1 removes any concurrency limitations. Default to -1. | `number` | `-1` | no |
| <a name="input_resource_id"></a> [resource\_id](#input\_resource\_id) | ID of the API Gateway resource (path) to attach Lambda to. | `string` | `""` | no |
| <a name="input_rest_api_id"></a> [rest\_api\_id](#input\_rest\_api\_id) | ID of the associated API Gateway REST API. | `string` | `""` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | n/a |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | n/a |
| <a name="output_lambda_arn"></a> [lambda\_arn](#output\_lambda\_arn) | n/a |
| <a name="output_lambda_execution_role_arn"></a> [lambda\_execution\_role\_arn](#output\_lambda\_execution\_role\_arn) | n/a |
| <a name="output_lambda_execution_role_name"></a> [lambda\_execution\_role\_name](#output\_lambda\_execution\_role\_name) | n/a |
| <a name="output_qualified_arn"></a> [qualified\_arn](#output\_qualified\_arn) | n/a |
| <a name="output_timeout"></a> [timeout](#output\_timeout) | n/a |
<!-- END_TF_DOCS -->
