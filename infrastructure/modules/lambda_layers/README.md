# Lambda Layer Module

## Features

- Creates a Lambda Layer version from a placeholder ZIP archive
- IAM policy for cross-role access to the layer
- Outputs layer ARN and policy ARN

---

## Usage

```hcl
module "lambda_layer" {
  source = "./modules/lambda-layer"

  # Required: AWS Account ID used in IAM policy generation
  account_id = "123456789012"

  # Required: Logical name for the Lambda Layer
  layer_name = "shared-utils"

  # Optional: Path to the zip file (relative to Terraform root)
  layer_zip_file_name = "shared-utils.zip"
}


```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
