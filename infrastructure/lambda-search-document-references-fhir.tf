module "search-document-references-fhir-lambda" {
  source  = "./modules/lambda"
  name    = "SearchDocumentReferencesFHIR"
  handler = "handlers.fhir_document_reference_search_handler.lambda_handler"
  iam_role_policy_documents = [
    module.document_reference_dynamodb_table.dynamodb_read_policy_document,
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.pdm_dynamodb_table.dynamodb_read_policy_document,
    module.pdm_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-document-store.s3_read_policy_document,
    module.ndr-app-config.app_config_policy
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = module.fhir_document_reference_gateway[0].gateway_resource_id
  http_methods        = ["GET"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION           = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT           = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION         = module.ndr-app-config.app_config_configuration_profile_id
    DYNAMODB_TABLE_LIST             = "[\u0022${module.pdm_dynamodb_table.table_name}\u0022, \u0022${module.lloyd_george_reference_dynamodb_table.table_name}\u0022]"
    DOCUMENT_RETRIEVE_ENDPOINT_APIM = "${local.apim_api_url}/DocumentReference"
    WORKSPACE                       = terraform.workspace
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.search-document-references-gateway,
    module.ndr-app-config,
    module.pdm_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table,
  ]
}

resource "aws_api_gateway_integration" "search_doc_fhir_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  resource_id             = module.fhir_document_reference_mtls_gateway.gateway_resource_id
  http_method             = "GET"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.search-document-references-fhir-lambda.invoke_arn

  depends_on = [module.fhir_document_reference_mtls_gateway]
}

resource "aws_lambda_permission" "lambda_permission_search_mtls_api" {
  statement_id  = "AllowMtlsApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.search-document-references-fhir-lambda.lambda_arn
  principal     = "apigateway.amazonaws.com"
  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.ndr_doc_store_api_mtls.execution_arn}/*/*"
}

