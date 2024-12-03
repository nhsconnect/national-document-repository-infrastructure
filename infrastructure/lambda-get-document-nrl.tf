resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id      = module.create-doc-ref-gateway.gateway_resource_id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

module "get-doc-nrl-lambda" {
  source  = "./modules/lambda"
  name    = "GetDocumentReference"
  handler = "handlers.get_doc.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    module.ndr-app-config.app_config_policy_arn
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.create-doc-ref-gateway.gateway_resource_id
  http_methods      = ["GET"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION   = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT   = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE               = terraform.workspace
    ENVIRONMENT             = var.environment
  }
}