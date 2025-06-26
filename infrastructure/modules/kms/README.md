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

<!-- END_TF_DOCS -->
