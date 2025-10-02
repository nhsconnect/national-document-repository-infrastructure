module "post-document-references-fhir-lambda" {
  source  = "./modules/lambda"
  name    = "PostDocumentReferencesFHIR"
  handler = "handlers.post_fhir_document_reference_handler.lambda_handler"
  iam_role_policy_documents = [
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.pdm_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy,
    aws_iam_policy.ssm_access_policy.policy
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = module.fhir_document_reference_gateway[0].gateway_resource_id
  http_methods        = ["POST"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION           = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT           = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION         = module.ndr-app-config.app_config_configuration_profile_id
    LLOYD_GEORGE_DYNAMODB_NAME      = module.lloyd_george_reference_dynamodb_table.table_name
    PDM_DYNAMODB_NAME               = module.pdm_dynamodb_table.table_name
    STAGING_STORE_BUCKET_NAME       = "${terraform.workspace}-${var.staging_store_bucket_name}"
    DOCUMENT_RETRIEVE_ENDPOINT_APIM = "${local.apim_api_url}/DocumentReference"
    PDS_FHIR_IS_STUBBED             = local.is_sandbox
    WORKSPACE                       = terraform.workspace
    PRESIGNED_ASSUME_ROLE           = aws_iam_role.create_post_presign_url_role.arn
  }

  depends_on = [
    module.pdm_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table,
  ]
}

resource "aws_api_gateway_integration" "post_doc_fhir_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ndr_doc_store_api_mtls.id
  resource_id             = module.fhir_document_reference_mtls_gateway.gateway_resource_id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.post-document-references-fhir-lambda.invoke_arn

  depends_on = [module.fhir_document_reference_mtls_gateway]

}

resource "aws_lambda_permission" "lambda_permission_post_mtls_api" {
  statement_id  = "AllowAPImTLSGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.post-document-references-fhir-lambda.lambda_arn
  principal     = "apigateway.amazonaws.com"
  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.ndr_doc_store_api_mtls.execution_arn}/*/*"
}

