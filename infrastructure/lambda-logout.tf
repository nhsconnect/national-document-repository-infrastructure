module "logout-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_resource.auth_resource.id
  http_method         = "GET"
  authorization       = "NONE"
  gateway_path        = "Logout"
  require_credentials = false
  origin              = "'https://${terraform.workspace}.${var.domain}'"
  # Lambda Variables
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  owner             = var.owner
  environment       = var.environment

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
  ]
}

module "logout_lambda" {
  source  = "./modules/lambda"
  name    = "LogoutHandler"
  handler = "handlers.logout_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    aws_iam_policy.ssm_policy_oidc.arn,
    module.auth_session_dynamodb_table.dynamodb_policy
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.logout-gateway.gateway_resource_id
  http_method       = "GET"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    WORKSPACE                      = terraform.workspace
    AUTH_DYNAMODB_NAME             = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
    SSM_PARAM_JWT_TOKEN_PUBLIC_KEY = "jwt_token_public_key"

  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_iam_policy.ssm_policy_oidc,
    module.auth_session_dynamodb_table,
  module.logout-gateway]
}

module "logout_alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.logout_lambda.function_name
  lambda_timeout       = module.logout_lambda.timeout
  lambda_name          = "logout_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.logout_alarm_topic.arn]
  ok_actions           = [module.logout_alarm_topic.arn]
  depends_on           = [module.logout_lambda, module.logout_alarm_topic]
}


module "logout_alarm_topic" {
  source         = "./modules/sns"
  topic_name     = "logout-alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.logout_lambda.endpoint
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

  depends_on = [module.logout_lambda]
}
