module "manage-nrl-pointer-lambda" {
  source         = "./modules/lambda"
  name           = "ManageNrlPointerLambda"
  handler        = "handlers.manage_nrl_pointer_handler.lambda_handler"
  lambda_timeout = 600
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    module.ndr-app-config.app_config_policy_arn,
    module.sqs-nrl-queue.sqs_policy,
    aws_iam_policy.ssm_access_policy.arn
  ]
  rest_api_id       = null
  api_execution_arn = null
  lambda_environment_variables = {
    APPCONFIG_APPLICATION   = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT   = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE               = terraform.workspace
    NRL_API_ENDPOINT        = local.is_production ? "https://${var.nrl_api_endpoint_suffix}" : "https://int.${var.nrl_api_endpoint_suffix}"
    NRL_END_USER_ODS_CODE   = data.aws_ssm_parameter.end_user_ods_code.name
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
}

module "manage-nrl-pointer-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.manage-nrl-pointer-lambda.function_name
  lambda_timeout       = module.manage-nrl-pointer-lambda.timeout
  lambda_name          = "manage_nrl_pointer_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.manage-nrl-pointer-alarm-topic.arn]
  ok_actions           = [module.manage-nrl-pointer-alarm-topic.arn]
}

module "manage-nrl-pointer-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "nrl-pointer-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.manage-nrl-pointer-lambda.lambda_arn
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

resource "aws_lambda_event_source_mapping" "nrl_pointer_lambda" {
  event_source_arn = module.sqs-nrl-queue.endpoint
  function_name    = module.manage-nrl-pointer-lambda.lambda_arn

  filter_criteria {
    filter {
      pattern = jsonencode({
        body = {
          "action" : [""]
        }
      })
    }
  }
}


data "aws_ssm_parameter" "end_user_ods_code" {
  name = "ndr_ods_code"
}