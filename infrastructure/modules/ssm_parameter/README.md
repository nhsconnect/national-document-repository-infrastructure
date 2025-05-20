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
