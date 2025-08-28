resource "aws_api_gateway_resource" "login_resource" {
  rest_api_id = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id   = aws_api_gateway_resource.auth_resource.id
  path_part   = "Login"

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api
  ]
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
  iam_role_policy_documents = [
    aws_iam_policy.ssm_access_policy.policy,
    module.auth_state_dynamodb_table.dynamodb_read_policy_document,
    module.auth_state_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = aws_api_gateway_resource.login_resource.id
  http_methods        = ["GET"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION   = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT   = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE               = terraform.workspace
    OIDC_CALLBACK_URL       = contains(["prod"], terraform.workspace) ? "https://${var.domain}/auth-callback" : "https://${terraform.workspace}.${var.domain}/auth-callback"
    AUTH_DYNAMODB_NAME      = "${terraform.workspace}_${var.auth_state_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    aws_api_gateway_resource.login_resource,
    aws_iam_policy.ssm_access_policy,
    module.auth_state_dynamodb_table,
    module.ndr-app-config
  ]
}

module "login_redirect_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.login_redirect_lambda.function_name
  lambda_timeout       = module.login_redirect_lambda.timeout
  lambda_name          = "login_redirect_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.login_redirect-alarm_topic.arn]
  ok_actions           = [module.login_redirect-alarm_topic.arn]
  depends_on           = [module.login_redirect_lambda, module.login_redirect-alarm_topic]
}


module "login_redirect-alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "login_redirect-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.login_redirect_lambda.lambda_arn
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

  depends_on = [module.login_redirect_lambda, module.sns_encryption_key]
}

