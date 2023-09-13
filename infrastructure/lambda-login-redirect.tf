resource "aws_api_gateway_resource" "login_resource" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  path_part   = "Login"
}

resource "aws_api_gateway_method" "login_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id   = aws_api_gateway_resource.login_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

module "login_redirect_lambda" {
  source  = "./modules/lambda"
  name    = "LoginRedirectHandler"
  handler = "handlers.login_redirect_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    aws_iam_policy.ssm_policy_oidc.arn,
    module.auth_state_dynamodb_table.dynamodb_policy
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.login_resource.id
  http_method       = "GET"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    WORKSPACE          = terraform.workspace
    OIDC_CALLBACK_URL  = "https://${terraform.workspace}.${var.domain}/auth-callback"
    AUTH_DYNAMODB_NAME = "${terraform.workspace}_${var.auth_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_api_gateway_resource.login_resource
  ]
}

resource "aws_iam_policy" "ssm_policy_oidc" {
  name = "${terraform.workspace}_ssm_oidc_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/*",
        ]
      }
    ]
  })
}