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

<!-- END_TF_DOCS -->
