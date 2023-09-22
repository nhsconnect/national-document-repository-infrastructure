resource "aws_api_gateway_resource" "logout_resource" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  path_part   = "Logout"
}

resource "aws_api_gateway_method" "logout_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id   = aws_api_gateway_resource.logout_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

module "logout_redirect_lambda" {
  source  = "./modules/lambda"
  name    = "LogoutHandler"
  handler = "handlers.logout_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    aws_iam_policy.ssm_policy_oidc.arn,
    module.auth_session_dynamodb_table.dynamodb_policy,
    module.jwt_signing_key_public.read_access_policy
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.logout_resource.id
  http_method       = "GET"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    WORKSPACE                      = terraform.workspace
    AUTH_DYNAMODB_NAME             = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
    SSM_PARAM_JWT_TOKEN_PUBLIC_KEY = module.jwt_signing_key_public.secret_name

  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_api_gateway_resource.logout_resource,
    module.jwt_signing_key_public
  ]
}
