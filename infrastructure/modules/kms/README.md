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

  # Required
  kms_key_name        = "app-secrets"
  kms_key_description = "KMS key used to encrypt application secrets"

  # Required
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

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.encryption_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_iam_policy_document.combined_policy_documents](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_generate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_decrypt_for_arn"></a> [allow\_decrypt\_for\_arn](#input\_allow\_decrypt\_for\_arn) | Flag to allow generating a decrypt-only policy for specified ARNs. | `bool` | `false` | no |
| <a name="input_allowed_arn"></a> [allowed\_arn](#input\_allowed\_arn) | List of ARNs that are allowed full encrypt/decrypt access to the KMS key. | `list(string)` | `[]` | no |
| <a name="input_aws_identifiers"></a> [aws\_identifiers](#input\_aws\_identifiers) | List of ARNs that will be granted decrypt-only access. | `list(string)` | `[]` | no |
| <a name="input_current_account_id"></a> [current\_account\_id](#input\_current\_account\_id) | AWS account ID where the KMS key policy is applied. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g., dev, staging, prod). | `string` | n/a | yes |
| <a name="input_kms_key_description"></a> [kms\_key\_description](#input\_kms\_key\_description) | Description of the KMS key. | `string` | n/a | yes |
| <a name="input_kms_key_name"></a> [kms\_key\_name](#input\_kms\_key\_name) | Name of the KMS key to be created. | `string` | n/a | yes |
| <a name="input_kms_key_rotation_enabled"></a> [kms\_key\_rotation\_enabled](#input\_kms\_key\_rotation\_enabled) | Enable automatic KMS key rotation. | `bool` | `true` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner tag for identifying the resource owner. | `string` | n/a | yes |
| <a name="input_service_identifiers"></a> [service\_identifiers](#input\_service\_identifiers) | List of AWS service principal identifiers allowed to use the key (e.g., 's3.amazonaws.com'). | `list(string)` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | n/a |
| <a name="output_kms_arn"></a> [kms\_arn](#output\_kms\_arn) | n/a |
<!-- END_TF_DOCS -->
