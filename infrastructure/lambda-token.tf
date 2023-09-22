resource "aws_api_gateway_resource" "token_request_resource" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  path_part   = "TokenRequest"
}

resource "aws_api_gateway_method" "token_request_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id   = aws_api_gateway_resource.token_request_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

module "create-token-lambda" {
  source  = "./modules/lambda"
  name    = "TokenRequestHandler"
  handler = "handlers.token_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    aws_iam_policy.ssm_policy_token.arn,
    module.auth_session_dynamodb_table.dynamodb_policy,
    module.auth_state_dynamodb_table.dynamodb_policy,
    module.jwt_signing_key_private.read_access_policy
  ]

  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = aws_api_gateway_resource.token_request_resource.id
  http_method       = "GET"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    WORKSPACE = terraform.workspace
    # SSM_PARAM_JWT_TOKEN_PRIVATE_KEY = "jwt_token_private_key"
    SSM_PARAM_JWT_TOKEN_PRIVATE_KEY = module.jwt_signing_key_private.secret_name
    OIDC_CALLBACK_URL               = "https://${terraform.workspace}.${var.domain}/auth-callback"
    AUTH_STATE_TABLE_NAME           = "${terraform.workspace}_${var.auth_state_dynamodb_table_name}"
    AUTH_SESSION_TABLE_NAME         = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_api_gateway_method.token_request_proxy_method,
    aws_iam_policy.ssm_policy_token,
    module.auth_session_dynamodb_table,
    module.auth_state_dynamodb_table,
    module.jwt_signing_key_private
  ]
  memory_size = 256
}

resource "aws_iam_policy" "ssm_policy_token" {
  name = "${terraform.workspace}_ssm_token_private_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
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
