# API Gateway Resource & CORS Module

## Features

- Creates a sub-resource under an existing API Gateway path
- Attaches multiple HTTP methods (e.g., GET, POST)
- Optional API Key enforcement
- Supports custom authorizers
- Full CORS support (OPTIONS method, headers, credentials)
- Outputs the created resource’s ID

---

## Usage

```hcl
module "api_gateway_resource" {
  source = "./modules/api-gateway-resource"

  # Required: ID of the existing REST API Gateway
  api_gateway_id = aws_api_gateway_rest_api.my_api.id

  # Required: Parent resource ID (e.g., the root path or another nested resource)
  parent_id = aws_api_gateway_resource.root.id

  # Required: New sub-path to create under the parent (e.g., "users", "status", etc.)
  gateway_path = "users"

  # Required: Allowed HTTP methods on this path (e.g., ["GET", "POST"])
  http_methods = ["GET", "POST"]

  # Required: Origin allowed for CORS requests (e.g., "*", or specific domain)
  origin = "https://example.com"

  # Required: Whether CORS preflight should allow credentials (cookies/auth headers)
  require_credentials = true

  # Required: Authorization type (e.g., NONE, AWS_IAM, CUSTOM)
  authorization = "CUSTOM"

  # Optional: Authorizer ID if using CUSTOM authorization
  authorizer_id = aws_api_gateway_authorizer.custom.id

  # Optional: Require an API key for access
  api_key_required = true
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

| Name                                                                                                                                                                                | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_api_gateway_integration.preflight_integration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration)                            | resource |
| [aws_api_gateway_integration_response.preflight_integration_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.preflight_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method)                                           | resource |
| [aws_api_gateway_method.proxy_method](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method)                                               | resource |
| [aws_api_gateway_method_response.preflight_method_response](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response)                | resource |
| [aws_api_gateway_resource.gateway_resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource)                                       | resource |

## Inputs

| Name                                                                                       | Description                                                                                         | Type           | Default | Required |
| ------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_api_gateway_id"></a> [api_gateway_id](#input_api_gateway_id)                | n/a                                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_api_key_required"></a> [api_key_required](#input_api_key_required)          | n/a                                                                                                 | `bool`         | `false` |    no    |
| <a name="input_authorization"></a> [authorization](#input_authorization)                   | n/a                                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_authorizer_id"></a> [authorizer_id](#input_authorizer_id)                   | Required resource id when setting authorization to 'CUSTOM'                                         | `string`       | `""`    |    no    |
| <a name="input_gateway_path"></a> [gateway_path](#input_gateway_path)                      | n/a                                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_http_methods"></a> [http_methods](#input_http_methods)                      | n/a                                                                                                 | `list(string)` | n/a     |   yes    |
| <a name="input_origin"></a> [origin](#input_origin)                                        | n/a                                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_parent_id"></a> [parent_id](#input_parent_id)                               | n/a                                                                                                 | `string`       | n/a     |   yes    |
| <a name="input_require_credentials"></a> [require_credentials](#input_require_credentials) | Sets the value of 'Access-Control-Allow-Credentials' which controls whether auth cookies are needed | `bool`         | n/a     |   yes    |

## Outputs

| Name                                                                                         | Description |
| -------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_gateway_resource_id"></a> [gateway_resource_id](#output_gateway_resource_id) | n/a         |

<!-- END_TF_DOCS -->
