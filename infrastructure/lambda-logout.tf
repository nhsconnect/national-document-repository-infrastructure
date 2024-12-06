module "logout-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_resource.auth_resource.id
  http_methods        = ["GET"]
  authorization       = "NONE"
  gateway_path        = "Logout"
  require_credentials = false
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
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
  iam_role_policy_documents = [
    aws_iam_policy.ssm_policy_oidc.policy,
    module.auth_session_dynamodb_table.dynamodb_read_policy_document,
    module.auth_session_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.logout-gateway.gateway_resource_id
  http_methods      = ["GET"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION          = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT          = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION        = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                      = terraform.workspace
    AUTH_DYNAMODB_NAME             = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
    SSM_PARAM_JWT_TOKEN_PUBLIC_KEY = "jwt_token_public_key"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_iam_policy.ssm_policy_oidc,
    module.auth_session_dynamodb_table,
    module.logout-gateway,
    module.ndr-app-config
  ]
}

module "logout_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.logout_lambda.function_name
  lambda_timeout       = module.logout_lambda.timeout
  lambda_name          = "logout_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.logout_alarm_topic.arn]
  ok_actions           = [module.logout_alarm_topic.arn]
  depends_on           = [module.logout_lambda, module.logout_alarm_topic]
}


module "logout_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "logout-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.logout_lambda.lambda_arn
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

  depends_on = [module.logout_lambda, module.sns_encryption_key]
}
