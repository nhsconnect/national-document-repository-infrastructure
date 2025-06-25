# KMS Encryption Key Module

## Features

- KMS key with optional rotation enabled
- KMS alias for easier referencing
- IAM policy granting:
  - Encryption/decryption access for specific ARNs
  - Permissions to AWS services (e.g., S3, Lambda)
- Optional `Decrypt`-only access for a secondary list of ARNs
- Output of KMS key ID and ARN for downstream use
- Fully tagged by owner and environment

---

## Usage

```hcl
module "kms_key" {
  source = "./modules/kms"

  # Required: The name for the KMS key and alias
  kms_key_name        = "app-secrets"
  kms_key_description = "KMS key used to encrypt application secrets"

  # Required: AWS environment and ownership
  environment          = "prod"
  owner                = "platform"
  current_account_id   = "123456789012"

  # Required: List of AWS services allowed to use this key (e.g., "s3.amazonaws.com", "lambda.amazonaws.com")
  service_identifiers = [
    "lambda.amazonaws.com"
  ]

  # Optional: Grant full access to these ARNs (encrypt/decrypt)
  allowed_arn = [
    "arn:aws:iam::123456789012:role/lambda-role"
  ]

  # Optional: Grant decrypt-only access to these ARNs
  allow_decrypt_for_arn = true
  aws_identifiers = [
    "arn:aws:iam::123456789012:user/readonly"
  ]

  # Optional: Enable automatic key rotation (recommended)
  kms_key_rotation_enabled = true
}


```

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

| Name                                                                                                                                                    | Type        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_kms_alias.encryption_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias)                             | resource    |
| [aws_kms_key.encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key)                                       | resource    |
| [aws_iam_policy_document.combined_policy_documents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)              | data source |
| [aws_iam_policy_document.kms_key_generate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)          | data source |

## Inputs

| Name                                                                                                      | Description | Type           | Default | Required |
| --------------------------------------------------------------------------------------------------------- | ----------- | -------------- | ------- | :------: |
| <a name="input_allow_decrypt_for_arn"></a> [allow_decrypt_for_arn](#input_allow_decrypt_for_arn)          | n/a         | `bool`         | `false` |    no    |
| <a name="input_allowed_arn"></a> [allowed_arn](#input_allowed_arn)                                        | n/a         | `list(string)` | `[]`    |    no    |
| <a name="input_aws_identifiers"></a> [aws_identifiers](#input_aws_identifiers)                            | n/a         | `list(string)` | `[]`    |    no    |
| <a name="input_current_account_id"></a> [current_account_id](#input_current_account_id)                   | n/a         | `string`       | n/a     |   yes    |
| <a name="input_environment"></a> [environment](#input_environment)                                        | n/a         | `string`       | n/a     |   yes    |
| <a name="input_kms_key_description"></a> [kms_key_description](#input_kms_key_description)                | n/a         | `string`       | n/a     |   yes    |
| <a name="input_kms_key_name"></a> [kms_key_name](#input_kms_key_name)                                     | n/a         | `string`       | n/a     |   yes    |
| <a name="input_kms_key_rotation_enabled"></a> [kms_key_rotation_enabled](#input_kms_key_rotation_enabled) | n/a         | `bool`         | `true`  |    no    |
| <a name="input_owner"></a> [owner](#input_owner)                                                          | n/a         | `string`       | n/a     |   yes    |
| <a name="input_service_identifiers"></a> [service_identifiers](#input_service_identifiers)                | n/a         | `list(string)` | n/a     |   yes    |

## Outputs

| Name                                                     | Description |
| -------------------------------------------------------- | ----------- |
| <a name="output_id"></a> [id](#output_id)                | n/a         |
| <a name="output_kms_arn"></a> [kms_arn](#output_kms_arn) | n/a         |

<!-- END_TF_DOCS -->
