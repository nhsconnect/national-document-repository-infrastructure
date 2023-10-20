module "authoriser-lambda" {
  source  = "./modules/lambda"
  name    = "AuthoriserLambda"
  handler = "handlers.authoriser_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    aws_iam_policy.ssm_policy_authoriser.arn,
    module.auth_session_dynamodb_table.dynamodb_policy,
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    WORKSPACE                      = terraform.workspace
    SSM_PARAM_JWT_TOKEN_PUBLIC_KEY = "jwt_token_public_key"
    AUTH_SESSION_TABLE_NAME        = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
  }
  http_method                   = "GET"
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = true

  depends_on = [
    aws_iam_policy.ssm_policy_authoriser,
    module.auth_session_dynamodb_table,
    aws_api_gateway_rest_api.ndr_doc_store_api
  ]
}

module "authoriser-alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.authoriser-lambda.function_name
  lambda_timeout       = module.authoriser-lambda.timeout
  lambda_name          = "authoriser_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.authoriser-alarm-topic.arn]
  ok_actions           = [module.authoriser-alarm-topic.arn]
  depends_on           = [module.authoriser-lambda, module.authoriser-alarm-topic]
}


module "authoriser-alarm-topic" {
  source         = "./modules/sns"
  topic_name     = "create_doc-alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.authoriser-lambda.endpoint
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

  depends_on = [module.authoriser-lambda]
}

resource "aws_api_gateway_authorizer" "repo_authoriser" {
  name            = "${terraform.workspace}_repo_authoriser"
  type            = "TOKEN"
  identity_source = "method.request.header.Authorization"
  rest_api_id     = aws_api_gateway_rest_api.ndr_doc_store_api.id
  authorizer_uri  = module.authoriser-lambda.invoke_arn
}

resource "aws_iam_policy" "ssm_policy_authoriser" {
  name = "${terraform.workspace}_ssm_public_token_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/jwt_token_public_key",
        ]
      }
    ]
  })
}

