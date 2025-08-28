resource "aws_api_gateway_resource" "get_document_reference" {
  count       = 1
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = module.fhir_document_reference_gateway[0].gateway_resource_id
  path_part   = "{id}"
}

resource "aws_api_gateway_method" "get_document_reference" {
  count            = 1
  rest_api_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id      = aws_api_gateway_resource.get_document_reference[0].id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
  request_parameters = {
    "method.request.path.id" = true
  }
}


module "get-doc-fhir-lambda" {
  count   = 1
  source  = "./modules/lambda"
  name    = "GetDocumentReference"
  handler = "handlers.get_fhir_document_reference_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-app-config.app_config_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    aws_iam_policy.ssm_access_policy.policy,
    module.ndr-lloyd-george-store.s3_read_policy_document,
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = aws_api_gateway_resource.get_document_reference[0].id
  http_methods        = ["GET"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    ENVIRONMENT                = var.environment
    PRESIGNED_ASSUME_ROLE      = aws_iam_role.get_fhir_doc_presign_url_role[0].arn
    LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    OIDC_CALLBACK_URL          = contains(["prod"], terraform.workspace) ? "https://${var.domain}/auth-callback" : "https://${terraform.workspace}.${var.domain}/auth-callback"
    CLOUDFRONT_URL             = module.cloudfront-distribution-lg.cloudfront_url
    PDS_FHIR_IS_STUBBED        = local.is_sandbox
  }
  depends_on = [aws_api_gateway_method.get_document_reference]
}

