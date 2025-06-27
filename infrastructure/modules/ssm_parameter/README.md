## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the parameter | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Tags | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of SSM parameter | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
| <a name="input_resource_depends_on"></a> [resource\_depends\_on](#input\_resource\_depends\_on) | n/a | `string` | `""` | no |
| <a name="input_type"></a> [type](#input\_type) | Valid types are String, StringList and SecureString. | `string` | `"SecureString"` | no |
| <a name="input_value"></a> [value](#input\_value) | Value of the parameter | `string` | `null` | no |

## Outputs

No outputs.
