# SSM Parameter Module

## Features

- Creates an SSM parameter with type `SecureString`, `String`, or `StringList`
- Optional description and custom naming
- SecureString defaults enabled for secrets
- Supports tagging with environment and owner
- Optional `depends_on` override

---

## Usage

```hcl
module "ssm_param" {
  source = "./modules/ssm-parameter"

  # Required: Environment and ownership tags
  environment = "prod"
  owner       = "platform"

  # Optional
  name = "/myapp/secret/token"

  # Optional
  description = "API token for service integration"

  # Required: Value to store
  value = var.api_token

  # Optional: Type of parameter — SecureString, String, or StringList
  type = "SecureString"

  # Optional: If another resource must be created first
  resource_depends_on = aws_kms_key.secret_key.id
}

```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
