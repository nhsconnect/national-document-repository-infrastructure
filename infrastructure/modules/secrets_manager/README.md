## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.allow_read_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_secretsmanager_secret.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the secret | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Tags | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of Secrets Manager secret | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
| <a name="input_resource_depends_on"></a> [resource\_depends\_on](#input\_resource\_depends\_on) | n/a | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_read_access_policy"></a> [read\_access\_policy](#output\_read\_access\_policy) | n/a |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | n/a |
