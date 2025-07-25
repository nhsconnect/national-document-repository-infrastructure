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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.lambda_layer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_lambda_layer_version.lambda_layer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource |
| [archive_file.lambda_layer_placeholder](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The AWS account ID used to generate IAM policy for layer access. | `string` | n/a | yes |
| <a name="input_layer_name"></a> [layer\_name](#input\_layer\_name) | Logical name assigned to the Lambda layer. | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_layer_arn"></a> [lambda\_layer\_arn](#output\_lambda\_layer\_arn) | Outputs |
| <a name="output_lambda_layer_policy_arn"></a> [lambda\_layer\_policy\_arn](#output\_lambda\_layer\_policy\_arn) | n/a |
<!-- END_TF_DOCS -->
