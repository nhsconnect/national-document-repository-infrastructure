resource "aws_api_gateway_resource" "get_document_reference" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = module.create-doc-ref-gateway.gateway_resource_id
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

module "get-doc-nrl-lambda" {
  source  = "./modules/lambda"
  name    = "GetDocumentReference"
  handler = "handlers.nrl_get_document_reference_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    module.ndr-app-config.app_config_policy_arn
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.get_document_reference.id
  http_methods      = ["GET"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    ENVIRONMENT                = var.environment
    PRESIGNED_ASSUME_ROLE      = aws_iam_role.nrl_get_doc_presign_url_role.arn
    LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    CLOUDFRONT_URL             = module.cloudfront-distribution-lg.cloudfront_url
  }
  depends_on = [aws_api_gateway_method.get_document_reference]
}