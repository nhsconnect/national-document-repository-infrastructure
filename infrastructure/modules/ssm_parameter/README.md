# SSM Parameter Module

This Terraform module provisions an AWS Systems Manager (SSM) parameter in the Parameter Store. It supports secure secrets (SecureString), plain text values, and configuration parameters. Useful for decoupling sensitive values from code or storing environment configuration per service.

---

## Features

- [x] Creates an SSM parameter with type `SecureString`, `String`, or `StringList`
- [x] Optional description and custom naming
- [x] SecureString defaults enabled for secrets
- [x] Supports tagging with environment and owner
- [x] Optional `depends_on` override

---

## Usage

```hcl
module "ssm_param" {
  source = "./modules/ssm-parameter"

  # Required: Environment and ownership tags
  environment = "prod"
  owner       = "platform"

  # Optional: Name of the parameter (if not set, Terraform will generate one)
  name = "/myapp/secret/token"

  # Optional: Description for context in the AWS Console
  description = "API token for service integration"

  # Required: Value to store (can be interpolated or sensitive)
  value = var.api_token

  # Optional: Type of parameter — SecureString, String, or StringList
  type = "SecureString"

  # Optional: If another resource must be created first
  resource_depends_on = aws_kms_key.secret_key.id
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

| Name                                                                                                                  | Type     |
| --------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_ssm_parameter.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name                                                                                       | Description                                          | Type     | Default          | Required |
| ------------------------------------------------------------------------------------------ | ---------------------------------------------------- | -------- | ---------------- | :------: |
| <a name="input_description"></a> [description](#input_description)                         | Description of the parameter                         | `string` | `null`           |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                         | Tags                                                 | `string` | n/a              |   yes    |
| <a name="input_name"></a> [name](#input_name)                                              | Name of SSM parameter                                | `string` | `null`           |    no    |
| <a name="input_owner"></a> [owner](#input_owner)                                           | n/a                                                  | `string` | n/a              |   yes    |
| <a name="input_resource_depends_on"></a> [resource_depends_on](#input_resource_depends_on) | n/a                                                  | `string` | `""`             |    no    |
| <a name="input_type"></a> [type](#input_type)                                              | Valid types are String, StringList and SecureString. | `string` | `"SecureString"` |    no    |
| <a name="input_value"></a> [value](#input_value)                                           | Value of the parameter                               | `string` | `null`           |    no    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
