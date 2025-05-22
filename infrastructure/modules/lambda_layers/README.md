# Lambda Layer Module

This Terraform module provisions an AWS Lambda Layer and attaches an optional IAM policy to control access. It packages and deploys a ZIP archive (either provided or default), enabling you to share libraries and dependencies across multiple Lambda functions.

This setup is useful for DRY infrastructure patterns where shared runtime logic (e.g., SDKs, custom utilities) is maintained independently of function code.

---

## Features

- [x] Creates a Lambda Layer version from a provided or placeholder ZIP archive
- [x] Configurable name and ZIP file input
- [x] IAM policy for cross-role access to the layer
- [x] Outputs layer ARN and policy ARN

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

No requirements.

## Providers

| Name                                                         | Version |
| ------------------------------------------------------------ | ------- |
| <a name="provider_archive"></a> [archive](#provider_archive) | n/a     |
| <a name="provider_aws"></a> [aws](#provider_aws)             | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                      | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.lambda_layer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)              | resource    |
| [aws_lambda_layer_version.lambda_layer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version) | resource    |
| [archive_file.lambda_layer_placeholder](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)          | data source |

## Inputs

| Name                                                                                       | Description | Type     | Default                            | Required |
| ------------------------------------------------------------------------------------------ | ----------- | -------- | ---------------------------------- | :------: |
| <a name="input_account_id"></a> [account_id](#input_account_id)                            | n/a         | `string` | n/a                                |   yes    |
| <a name="input_layer_name"></a> [layer_name](#input_layer_name)                            | n/a         | `string` | n/a                                |   yes    |
| <a name="input_layer_zip_file_name"></a> [layer_zip_file_name](#input_layer_zip_file_name) | n/a         | `string` | `"placeholder_lambda_payload.zip"` |    no    |

## Outputs

| Name                                                                                                     | Description |
| -------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_lambda_layer_arn"></a> [lambda_layer_arn](#output_lambda_layer_arn)                      | Outputs     |
| <a name="output_lambda_layer_policy_arn"></a> [lambda_layer_policy_arn](#output_lambda_layer_policy_arn) | n/a         |

<!-- END_TF_DOCS -->
