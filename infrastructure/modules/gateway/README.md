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
| [aws_api_gateway_integration.preflight_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.preflight_integration_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.preflight_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.proxy_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.preflight_method_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_resource.gateway_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_execution_arn"></a> [api\_execution\_arn](#input\_api\_execution\_arn) | n/a | `string` | n/a | yes |
| <a name="input_api_gateway_id"></a> [api\_gateway\_id](#input\_api\_gateway\_id) | n/a | `string` | n/a | yes |
| <a name="input_authorization"></a> [authorization](#input\_authorization) | n/a | `string` | n/a | yes |
| <a name="input_authorizer_id"></a> [authorizer\_id](#input\_authorizer\_id) | Required resource id when setting authorization to 'CUSTOM' | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_gateway_path"></a> [gateway\_path](#input\_gateway\_path) | n/a | `string` | n/a | yes |
| <a name="input_http_methods"></a> [http\_methods](#input\_http\_methods) | n/a | `list(string)` | n/a | yes |
| <a name="input_origin"></a> [origin](#input\_origin) | n/a | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | n/a | `string` | n/a | yes |
| <a name="input_require_credentials"></a> [require\_credentials](#input\_require\_credentials) | Sets the value of 'Access-Control-Allow-Credentials' which controls whether auth cookies are needed | `bool` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_resource_id"></a> [gateway\_resource\_id](#output\_gateway\_resource\_id) | n/a |
