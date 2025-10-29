resource "aws_api_gateway_resource" "gateway_resource" {
  rest_api_id = var.api_gateway_id
  parent_id   = var.parent_id
  path_part   = var.gateway_path
}

resource "aws_api_gateway_method" "preflight_method" {
  rest_api_id   = var.api_gateway_id
  resource_id   = aws_api_gateway_resource.gateway_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
  depends_on    = [aws_api_gateway_resource.gateway_resource]
}

resource "aws_api_gateway_method" "proxy_method" {
  for_each           = toset(var.http_methods)
  rest_api_id        = var.api_gateway_id
  resource_id        = aws_api_gateway_resource.gateway_resource.id
  http_method        = each.key
  authorization      = var.authorization
  authorizer_id      = var.authorizer_id
  api_key_required   = var.api_key_required
  request_parameters = var.request_parameters
}

resource "aws_api_gateway_method_response" "preflight_method_response" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_resource.gateway_resource.id
  http_method = aws_api_gateway_method.preflight_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = true,
    "method.response.header.Access-Control-Allow-Methods"     = true,
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Credentials" = var.require_credentials
  }
  depends_on = [aws_api_gateway_method.preflight_method, aws_api_gateway_resource.gateway_resource]
}

resource "aws_api_gateway_integration" "preflight_integration" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_resource.gateway_resource.id
  http_method = aws_api_gateway_method.preflight_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = <<EOF
{
   "statusCode" : 200
}
EOF
  }
  depends_on = [aws_api_gateway_method.preflight_method, aws_api_gateway_resource.gateway_resource]
}

resource "aws_api_gateway_integration_response" "preflight_integration_response" {
  rest_api_id = var.api_gateway_id
  resource_id = aws_api_gateway_resource.gateway_resource.id
  http_method = aws_api_gateway_method.preflight_method.http_method
  status_code = aws_api_gateway_method_response.preflight_method_response.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Auth,Cookie,X-Api-Key,X-Amz-Security-Token,X-Auth-Cookie,Accept'",
    "method.response.header.Access-Control-Allow-Methods"     = "'${join(", ", var.http_methods)}'",
    "method.response.header.Access-Control-Allow-Origin"      = var.origin,
    "method.response.header.Access-Control-Allow-Credentials" = "'${var.require_credentials}'"

  }
  depends_on = [aws_api_gateway_method_response.preflight_method_response, aws_api_gateway_resource.gateway_resource]
}
