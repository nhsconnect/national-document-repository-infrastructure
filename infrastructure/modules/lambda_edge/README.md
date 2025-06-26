# Lambda Proxy for S3 Access Module

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

<!-- END_TF_DOCS -->
