# New API Gateway for mTLS
resource "aws_api_gateway_rest_api" "ndr_doc_store_api_mtls" {
  name        = "${terraform.workspace}_DocStoreApiMtls"
  description = "Document store API with mTLS enabled"

  tags = {
    Name = "${terraform.workspace}_DocStoreApiMtls"
  }
}

resource "aws_api_gateway_domain_name" "custom_api_domain_mtls" {
  domain_name              = local.mtls_api_gateway_full_domain_name
  regional_certificate_arn = aws_acm_certificate_validation.mtls_api_gateway_cert.certificate_arn
  security_policy          = "TLS_1_2"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri = "s3://${terraform.workspace}-${var.truststore_bucket_name}/${var.ca_pem_filename}"
  }
}

resource "aws_api_gateway_base_path_mapping" "api_mapping_mtls" {
  api_id      = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  stage_name  = var.environment
  domain_name = aws_api_gateway_domain_name.custom_api_domain_mtls.domain_name

  depends_on = [aws_api_gateway_deployment.ndr_api_deploy_mtls]
}

resource "aws_api_gateway_deployment" "ndr_api_deploy_mtls" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api_mtls,
    aws_api_gateway_resource.get_document_reference_mtls,
    module.get-doc-fhir-lambda,
    aws_api_gateway_integration.get_doc_fhir_lambda_integration,
    aws_lambda_permission.lambda_permission_get_mtls_api,
    module.post-document-references-fhir-lambda,
    aws_api_gateway_integration.post_doc_fhir_lambda_integration,
    aws_lambda_permission.lambda_permission_post_mtls_api,
    module.search-document-references-fhir-lambda,
    aws_api_gateway_integration.search_doc_fhir_lambda_integration,
    aws_lambda_permission.lambda_permission_search_mtls_api,
  ]

  lifecycle {
    create_before_destroy = true
  }

  variables = {
    deployed_at = timestamp()
  }
}

resource "aws_api_gateway_stage" "ndr_api_mtls" {
  deployment_id        = aws_api_gateway_deployment.ndr_api_deploy_mtls.id
  rest_api_id          = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  stage_name           = var.environment
  xray_tracing_enabled = var.enable_xray_tracing
}

resource "aws_cloudwatch_log_group" "mtls_api_gateway_stage" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id}/${var.environment}"
  retention_in_days = 0
  depends_on = [
    aws_api_gateway_account.logging
  ]
}

resource "aws_api_gateway_method_settings" "mtls_api_gateway_stage" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  stage_name  = aws_api_gateway_stage.ndr_api_mtls.stage_name
  method_path = "*/*"

  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
    data_trace_enabled = true
  }
}

resource "aws_api_gateway_gateway_response" "unauthorised_response_mtls" {
  rest_api_id   = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  response_type = "DEFAULT_4XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"      = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Auth,X-Api-Key,X-Amz-Security-Token,X-Auth-Cookie,Accept'"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'"
  }
}

resource "aws_api_gateway_gateway_response" "bad_gateway_response_mtls" {
  rest_api_id   = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  response_type = "DEFAULT_5XX"

  response_templates = {
    "application/json" = "{\"message\":$context.error.messageString}"
  }

  response_parameters = {
    "gatewayresponse.header.Access-Control-Allow-Origin"      = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
    "gatewayresponse.header.Access-Control-Allow-Methods"     = "'*'"
    "gatewayresponse.header.Access-Control-Allow-Headers"     = "'Content-Type,X-Amz-Date,Authorization,X-Auth,X-Api-Key,X-Amz-Security-Token,X-Auth-Cookie,Accept'"
    "gatewayresponse.header.Access-Control-Allow-Credentials" = "'true'"
  }
}

module "mtls_api_endpoint_url_ssm_parameter" {
  source              = "./modules/ssm_parameter"
  name                = "${terraform.workspace}_ApiEndpointMtls"
  description         = "mTLS api endpoint URL for ${var.environment}"
  resource_depends_on = aws_api_gateway_deployment.ndr_api_deploy_mtls
  value               = "https://${aws_api_gateway_base_path_mapping.api_mapping_mtls.domain_name}"
  type                = "SecureString"
  owner               = var.owner
  environment         = var.environment
}