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

<!-- END_TF_DOCS -->
