module "feature-flags-gateway" {
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["GET"]
  authorization       = "CUSTOM"
  gateway_path        = "FeatureFlags"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
}

module "feature_flags_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.feature-flags-lambda.function_name
  lambda_timeout       = module.feature-flags-lambda.timeout
  lambda_name          = "feature_flags_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.feature_flags_alarm_topic.arn]
  ok_actions           = [module.feature_flags_alarm_topic.arn]
  depends_on           = [module.feature-flags-lambda, module.feature_flags_alarm_topic]
}


module "feature_flags_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "feature_flags_alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.feature-flags-lambda.lambda_arn
  depends_on            = [module.sns_encryption_key]
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
}

module "feature-flags-lambda" {
  source  = "./modules/lambda"
  name    = "FeatureFlagsLambda"
  handler = "handlers.feature_flags_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-app-config.app_config_policy,
    aws_iam_policy.ssm_access_policy.policy,
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = module.feature-flags-gateway.gateway_resource_id
  http_methods        = ["GET"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn

  lambda_timeout = 450

  lambda_environment_variables = {
    APPCONFIG_APPLICATION   = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT   = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE               = terraform.workspace
  }

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.feature-flags-gateway,
    module.ndr-app-config
  ]
}
