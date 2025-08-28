module "back-channel-logout-gateway" {
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_resource.auth_resource.id
  http_methods        = ["POST"]
  authorization       = "NONE"
  gateway_path        = "BackChannelLogout"
  require_credentials = false
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
}

module "back_channel_logout_lambda" {
  source  = "./modules/lambda"
  name    = "BackChannelLogoutHandler"
  handler = "handlers.back_channel_logout_handler.lambda_handler"
  iam_role_policy_documents = [
    aws_iam_policy.ssm_access_policy.policy,
    module.auth_session_dynamodb_table.dynamodb_read_policy_document,
    module.auth_session_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = module.back-channel-logout-gateway.gateway_resource_id
  http_methods        = ["POST"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION          = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT          = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION        = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                      = terraform.workspace
    ENVIRONMENT                    = var.environment
    AUTH_DYNAMODB_NAME             = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
    SSM_PARAM_JWT_TOKEN_PUBLIC_KEY = "jwt_token_public_key"
    OIDC_CALLBACK_URL              = contains(["prod"], terraform.workspace) ? "https://${var.domain}/auth-callback" : "https://${terraform.workspace}.${var.domain}/auth-callback"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_iam_policy.ssm_access_policy,
    module.auth_session_dynamodb_table,
    module.back-channel-logout-gateway,
    module.ndr-app-config
  ]
}

module "back_channel_logout_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.back_channel_logout_lambda.function_name
  lambda_timeout       = module.back_channel_logout_lambda.timeout
  lambda_name          = "back_channel_logout_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.back_channel_logout_alarm_topic.arn]
  ok_actions           = [module.back_channel_logout_alarm_topic.arn]
  depends_on           = [module.back_channel_logout_lambda, module.back_channel_logout_alarm_topic]
}


module "back_channel_logout_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "back-channel-logout-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.back_channel_logout_lambda.lambda_arn
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

  depends_on = [module.back_channel_logout_lambda, module.sns_encryption_key]
}
