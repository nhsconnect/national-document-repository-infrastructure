module "manage-nrl-pointer-lambda" {
  source         = "./modules/lambda"
  name           = "ManageNrlPointerLambda"
  handler        = "handlers.manage_nrl_pointer_handler.lambda_handler"
  lambda_timeout = 600
  iam_role_policy_documents = [
    module.ndr-app-config.app_config_policy,
    module.sqs-nrl-queue.sqs_read_policy_document,
    module.sqs-nrl-queue.sqs_write_policy_document,
    aws_iam_policy.ssm_access_policy.policy
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

  depends_on = [
    module.ndr-app-config
  ]
}

module "manage-nrl-pointer-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.manage-nrl-pointer-lambda.function_name
  lambda_timeout       = module.manage-nrl-pointer-lambda.timeout
  lambda_name          = "manage_nrl_pointer_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.manage-nrl-pointer-alarm-topic.arn]
  ok_actions           = [module.manage-nrl-pointer-alarm-topic.arn]
  depends_on           = [module.manage-nrl-pointer-lambda, module.manage-nrl-pointer-alarm-topic]
}

module "manage-nrl-pointer-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
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

  depends_on = [module.manage-nrl-pointer-lambda, module.sns_encryption_key]
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

  scaling_config {
    maximum_concurrency = local.bulk_upload_lambda_concurrent_limit
  }

  depends_on = [
    module.sqs-nrl-queue,
    module.manage-nrl-pointer-lambda
  ]
}


data "aws_ssm_parameter" "end_user_ods_code" {
  name = "ndr_ods_code"
}
