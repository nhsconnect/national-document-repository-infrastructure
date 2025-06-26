module "post-document-references-fhir-lambda" {
  count   = local.is_production ? 0 : 1
  source  = "./modules/lambda"
  name    = "PostDocumentReferencesFHIR"
  handler = "handlers.post_fhir_document_reference_handler.lambda_handler"
  iam_role_policy_documents = [
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy,
    aws_iam_policy.ssm_access_policy.policy
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.document_reference_gateway.gateway_resource_id
  http_methods      = ["POST"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION           = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT           = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION         = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_DYNAMODB_NAME    = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME      = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    STAGING_STORE_BUCKET_NAME       = "${terraform.workspace}-${var.staging_store_bucket_name}"
    DOCUMENT_RETRIEVE_ENDPOINT_APIM = "${local.apim_api_url}/DocumentReference"
    PDS_FHIR_IS_STUBBED             = local.is_sandbox
    WORKSPACE                       = terraform.workspace
    PRESIGNED_ASSUME_ROLE           = aws_iam_role.create_post_presign_url_role.arn
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
  ]
}
