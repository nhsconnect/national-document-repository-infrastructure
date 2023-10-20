module "token-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_resource.auth_resource.id
  http_method         = "GET"
  authorization       = "NONE"
  gateway_path        = "TokenRequest"
  require_credentials = false
  origin              = "'https://${terraform.workspace}.${var.domain}'"
  # Lambda Variables
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  owner             = var.owner
  environment       = var.environment

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_api_gateway_authorizer.repo_authoriser
  ]
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
    module.auth_state_dynamodb_table.dynamodb_policy
  ]

  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.token-gateway.gateway_resource_id
  http_method       = "GET"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    WORKSPACE                       = terraform.workspace
    SSM_PARAM_JWT_TOKEN_PRIVATE_KEY = "jwt_token_private_key"
    OIDC_CALLBACK_URL               = "https://${terraform.workspace}.${var.domain}/auth-callback"
    AUTH_STATE_TABLE_NAME           = "${terraform.workspace}_${var.auth_state_dynamodb_table_name}"
    AUTH_SESSION_TABLE_NAME         = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_iam_policy.ssm_policy_token,
    module.auth_session_dynamodb_table,
    module.auth_state_dynamodb_table,
    module.token-gateway
  ]
  memory_size = 256
}

module "create_token-alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.create-token-lambda.function_name
  lambda_timeout       = module.create-token-lambda.timeout
  lambda_name          = "token_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.create_token-alarm_topic.arn]
  ok_actions           = [module.create_token-alarm_topic.arn]
  depends_on           = [module.create-token-lambda, module.create_token-alarm_topic]
}


module "create_token-alarm_topic" {
  source         = "./modules/sns"
  topic_name     = "logout-alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.create-token-lambda.endpoint
  delivery_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "cloudwatch.amazonaws.com"
        },
        "Action" : [
          "SNS:Publish",
        ],
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cloudwatch:eu-west-2:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
        "Resource" : "*"
      }
    ]
  })

  depends_on = [module.create-token-lambda]
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