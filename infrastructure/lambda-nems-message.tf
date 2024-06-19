module "nems-message-lambda" {
  count          = 1
  source         = "./modules/lambda"
  name           = "NemsMessageLambda"
  handler        = "handlers.nems_message_handler.lambda_handler"
  lambda_timeout = 60
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    module.sqs-nems-queue[0].sqs_policy,
    module.ndr-app-config.app_config_policy_arn
  ]
  rest_api_id       = null
  api_execution_arn = null

  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    NEMS_SQS_QUEUE_URL         = module.sqs-nems-queue[0].sqs_url
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false

  depends_on = [
    module.lloyd_george_reference_dynamodb_table,
    module.sqs-nems-queue,
    module.ndr-app-config
  ]
}

module "nems-message-lambda-alarm" {
  count                = 1
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.nems-message-lambda[0].function_name
  lambda_timeout       = module.nems-message-lambda[0].timeout
  lambda_name          = "nems_message_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.nems-message-lambda-alarm-topic[0].arn]
  ok_actions           = [module.nems-message-lambda-alarm-topic[0].arn]
  depends_on           = [module.nems-message-lambda, module.nems-message-lambda-alarm-topic]
}

module "nems-message-lambda-alarm-topic" {
  count                 = 1
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "nems-message-lambda-alarm-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.nems-message-lambda[0].endpoint
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

  depends_on = [module.nems-message-lambda, module.sns_encryption_key]
}

resource "aws_lambda_event_source_mapping" "nems_message_lambda" {
  count                   = 1
  event_source_arn        = module.sqs-nems-queue[0].endpoint
  function_name           = module.nems-message-lambda[0].endpoint
  function_response_types = ["ReportBatchItemFailures"]
  depends_on = [
    module.sqs-nems-queue,
    module.nems-message-lambda
  ]
}
