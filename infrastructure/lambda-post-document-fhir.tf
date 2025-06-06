resource "aws_api_gateway_method" "post_document_references_fhir" {
  count            = local.is_production ? 0 : 1
  rest_api_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id      = module.document_reference_gateway.gateway_resource_id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}


module "upload-document-references-fhir-lambda" {
  count   = local.is_production ? 0 : 1
  source  = "./modules/lambda"
  name    = "UploadDocumentReferencesFHIR"
  handler = "handlers.fhir_document_reference_upload_handler.lambda_handler"
  iam_role_policy_documents = [
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-document-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.document_reference_gateway.gateway_resource_id
  http_methods      = ["POST"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION           = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT           = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION         = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_BUCKET_NAME      = "${terraform.workspace}-${var.docstore_bucket_name}"
    DOCUMENT_STORE_DYNAMODB_NAME    = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME      = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    LLOYD_GEORGE_BUCKET_NAME        = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    DOCUMENT_RETRIEVE_ENDPOINT_APIM = "${local.apim_api_url}/DocumentReference"
    WORKSPACE                       = terraform.workspace
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.search-document-references-gateway,
    module.ndr-app-config
  ]
}
