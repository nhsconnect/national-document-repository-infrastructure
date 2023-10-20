resource "aws_api_gateway_resource" "login_resource" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_resource.auth_resource.id
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
    AUTH_DYNAMODB_NAME = "${terraform.workspace}_${var.auth_state_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_api_gateway_resource.login_resource,
    aws_iam_policy.ssm_policy_oidc,
    module.auth_state_dynamodb_table
  ]
}

module "login_redirect_alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.login_redirect_lambda.function_name
  lambda_timeout       = module.login_redirect_lambda.timeout
  lambda_name          = "authoriser_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.login_redirect-alarm_topic.arn]
  ok_actions           = [module.login_redirect-alarm_topic.arn]
  depends_on           = [module.login_redirect_lambda, module.login_redirect-alarm_topic]
}


module "login_redirect-alarm_topic" {
  source         = "./modules/sns"
  topic_name     = "login_redirect-alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.login_redirect_lambda.endpoint
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

  depends_on = [module.login_redirect_lambda]
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
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/*",
        ]
      }
    ]
  })
}