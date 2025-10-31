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

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
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
| <a name="input_api_gateway_id"></a> [api\_gateway\_id](#input\_api\_gateway\_id) | ID of the existing API Gateway REST API. | `string` | n/a | yes |
| <a name="input_api_key_required"></a> [api\_key\_required](#input\_api\_key\_required) | Whether an API key is required to access this resource. | `bool` | `false` | no |
| <a name="input_authorization"></a> [authorization](#input\_authorization) | Authorization type for the method (e.g., NONE, AWS\_IAM, CUSTOM). | `string` | n/a | yes |
| <a name="input_authorizer_id"></a> [authorizer\_id](#input\_authorizer\_id) | Required resource id when setting authorization to 'CUSTOM'. | `string` | `""` | no |
| <a name="input_gateway_path"></a> [gateway\_path](#input\_gateway\_path) | Sub-path to create under the parent resource (e.g., users, status). | `string` | n/a | yes |
| <a name="input_http_methods"></a> [http\_methods](#input\_http\_methods) | List of allowed HTTP methods for the resource (e.g., ["GET", "POST"]). | `list(string)` | n/a | yes |
| <a name="input_origin"></a> [origin](#input\_origin) | Allowed origin for CORS requests (e.g., '*', or specific domain). | `string` | `"'*'"` | no |
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | ID of the parent API Gateway resource (e.g., root path or another nested resource). | `string` | n/a | yes |
| <a name="input_request_parameters"></a> [request\_parameters](#input\_request\_parameters) | Request parameters for the API Gateway method. | `map(string)` | `{}` | no |
| <a name="input_require_credentials"></a> [require\_credentials](#input\_require\_credentials) | Sets the value of 'Access-Control-Allow-Credentials' which controls whether auth cookies are needed. | `bool` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway_resource_id"></a> [gateway\_resource\_id](#output\_gateway\_resource\_id) | n/a |
<!-- END_TF_DOCS -->
