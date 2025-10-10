resource "aws_api_gateway_resource" "get_document_reference" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = module.fhir_document_reference_gateway[0].gateway_resource_id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "get_document_reference_mtls" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  parent_id   = module.fhir_document_reference_mtls_gateway.gateway_resource_id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_document_reference" {
  rest_api_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id      = aws_api_gateway_resource.get_document_reference.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
  request_parameters = {
    "method.request.path.id" = true
  }
}

resource "aws_api_gateway_method" "get_document_reference_mtls" {
  rest_api_id      = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  resource_id      = aws_api_gateway_resource.get_document_reference_mtls.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.id" = true
  }
}


module "get-doc-fhir-lambda" {
  source  = "./modules/lambda"
  name    = "GetDocumentReference"
  handler = "handlers.get_fhir_document_reference_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-app-config.app_config_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.pdm_dynamodb_table.dynamodb_read_policy_document,
    aws_iam_policy.ssm_access_policy.policy,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.pdm-document-store.s3_read_policy_document,
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = aws_api_gateway_resource.get_document_reference.id
  http_methods        = ["GET"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    ENVIRONMENT                = var.environment
    PRESIGNED_ASSUME_ROLE      = aws_iam_role.get_fhir_doc_presign_url_role.arn
    LLOYD_GEORGE_DYNAMODB_NAME = module.lloyd_george_reference_dynamodb_table.table_name
    PDM_DYNAMODB_NAME          = module.pdm_dynamodb_table.table_name
    OIDC_CALLBACK_URL          = contains(["prod"], terraform.workspace) ? "https://${var.domain}/auth-callback" : "https://${terraform.workspace}.${var.domain}/auth-callback"
    CLOUDFRONT_URL             = module.cloudfront-distribution-lg.cloudfront_url
    PDS_FHIR_IS_STUBBED        = local.is_sandbox
  }
  depends_on = [
    aws_api_gateway_method.get_document_reference,
    module.pdm_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table,
  ]
}

resource "aws_api_gateway_integration" "get_doc_fhir_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  resource_id             = aws_api_gateway_resource.get_document_reference_mtls.id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.get-doc-fhir-lambda.invoke_arn

  depends_on = [aws_api_gateway_method.get_document_reference_mtls]

}

resource "aws_lambda_permission" "lambda_permission_get_mtls_api" {
  statement_id  = "AllowAPImTLSGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.get-doc-fhir-lambda.lambda_arn
  principal     = "apigateway.amazonaws.com"
  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.ndr_doc_store_api_mtls.execution_arn}/*/*"
}

