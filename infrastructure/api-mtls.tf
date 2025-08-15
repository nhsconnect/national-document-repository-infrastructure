# New API Gateway for mTLS
resource "aws_api_gateway_rest_api" "mtls_doc_store_api" {
  name        = "${terraform.workspace}-MTLS-DocStoreAPI"
  description = "Use-case agnostic API Gateway with mTLS enabled"

  tags = {
    Name        = "${terraform.workspace}-mtls-docstore-api"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_api_gateway_domain_name" "mtls_custom_api_domain" {
  domain_name              = local.mtls_api_gateway_full_domain_name
  regional_certificate_arn = aws_acm_certificate_validation.main.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri = "s3://${terraform.workspace}-${var.trustore_bucket_name}/${var.ca_pem_filename}"
  }
}

resource "aws_api_gateway_base_path_mapping" "mtls_api_mapping" {
  api_id      = aws_api_gateway_rest_api.mtls_doc_store_api.id
  stage_name  = var.environment
  domain_name = aws_api_gateway_domain_name.mtls_custom_api_domain.domain_name

  depends_on = [aws_api_gateway_deployment.mtls_api_deploy]
}

# Mock integration for testing POC
resource "aws_api_gateway_resource" "mtls_test_mock" {
  rest_api_id = aws_api_gateway_rest_api.mtls_doc_store_api.id
  parent_id   = aws_api_gateway_rest_api.mtls_doc_store_api.root_resource_id
  path_part   = "test_mock"
}

resource "aws_api_gateway_method" "mtls_test_mock_method" {
  rest_api_id   = aws_api_gateway_rest_api.mtls_doc_store_api.id
  resource_id   = aws_api_gateway_resource.mtls_test_mock.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mtls_test_mock_integration" {
  rest_api_id             = aws_api_gateway_rest_api.mtls_doc_store_api.id
  resource_id             = aws_api_gateway_resource.mtls_test_mock.id
  http_method             = aws_api_gateway_method.mtls_test_mock_method.http_method
  type                    = "MOCK"
  integration_http_method = "GET"

  request_templates = {
    "application/json" = <<EOF
{
  "statusCode": 200
}
EOF
  }
}

resource "aws_api_gateway_method_response" "mtls_test_mock_response" {
  rest_api_id = aws_api_gateway_rest_api.mtls_doc_store_api.id
  resource_id = aws_api_gateway_resource.mtls_test_mock.id
  http_method = aws_api_gateway_method.mtls_test_mock_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "mtls_test_mock_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.mtls_doc_store_api.id
  resource_id = aws_api_gateway_resource.mtls_test_mock.id
  http_method = aws_api_gateway_method.mtls_test_mock_method.http_method
  status_code = aws_api_gateway_method_response.mtls_test_mock_response.status_code

  response_templates = {
    "application/json" = <<EOF
{
  "message": "Hello from mTLS MOCK endpoint!"
}
EOF
  }
}

resource "aws_api_gateway_deployment" "mtls_api_deploy" {
  rest_api_id = aws_api_gateway_rest_api.mtls_doc_store_api.id


  depends_on = [
    aws_api_gateway_method.mtls_test_mock_method,
    aws_api_gateway_integration.mtls_test_mock_integration,
    aws_api_gateway_method_response.mtls_test_mock_response,
    aws_api_gateway_integration_response.mtls_test_mock_integration_response
  ]

  lifecycle {
    create_before_destroy = true
  }

  variables = {
    deployed_at = timestamp()
  }
}

resource "aws_api_gateway_stage" "mtls_api" {
  deployment_id        = aws_api_gateway_deployment.mtls_api_deploy.id
  rest_api_id          = aws_api_gateway_rest_api.mtls_doc_store_api.id
  stage_name           = var.environment
  xray_tracing_enabled = var.enable_xray_tracing
}

resource "aws_cloudwatch_log_group" "mtls_api_gateway_stage" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.mtls_doc_store_api.id}/${var.environment}"
  retention_in_days = 0
}

resource "aws_api_gateway_method_settings" "mtls_api_gateway_stage" {
  rest_api_id = aws_api_gateway_rest_api.mtls_doc_store_api.id
  stage_name  = aws_api_gateway_stage.mtls_api.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true
  }
}

module "mtls_api_endpoint_url_ssm_parameter" {
  source              = "./modules/ssm_parameter"
  name                = "mtls_api_endpoint"
  description         = "mTLS API endpoint URL for ${var.environment}"
  resource_depends_on = aws_api_gateway_deployment.mtls_api_deploy
  value               = "https://${aws_api_gateway_base_path_mapping.mtls_api_mapping.domain_name}"
  type                = "SecureString"
  owner               = var.owner
  environment         = var.environment
}
