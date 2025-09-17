module "search_document_references_lambda" {
  source  = "./modules/lambda"
  name    = "SearchDocumentReferences"
  handler = "handlers.search_document_reference_handler_fhir.lambda_handler"
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
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  resource_id         = module.fhir_document_reference_mtls_gateway.gateway_resource_id
  http_methods        = ["GET"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.execution_arn
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
