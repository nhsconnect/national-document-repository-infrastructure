module "mns-notification-lambda" {
  source  = "./modules/lambda"
  name    = "MNSNotificationLambda"
  handler = "handlers.mns_notification_handler.lambda_handler"
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    module.sqs-mns-notification-queue.sqs_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    aws_iam_policy.ssm_access_policy.arn,
    module.ndr-app-config.app_config_policy_arn,
    aws_iam_policy.kms_lambda_access.arn,
  ]
  rest_api_id       = null
  api_execution_arn = null

  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    MNS_NOTIFICATION_QUEUE_URL = module.sqs-mns-notification-queue.sqs_url
    PDS_FHIR_IS_STUBBED        = local.is_sandbox
  }

  is_gateway_integration_needed  = false
  is_invoked_from_gateway        = false
  lambda_timeout                 = 900
  reserved_concurrent_executions = local.mns_notification_lambda_concurrent_limit
}

resource "aws_lambda_event_source_mapping" "mns_notification_lambda" {
  event_source_arn = module.sqs-mns-notification-queue.endpoint
  function_name    = module.mns-notification-lambda.lambda_arn

  scaling_config {
    maximum_concurrency = local.mns_notification_lambda_concurrent_limit
  }
}

module "mns-notification-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.mns-notification-lambda.function_name
  lambda_timeout       = module.mns-notification-lambda.timeout
  lambda_name          = "mns_notification_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.mns-notification-alarm-topic.arn]
  ok_actions           = [module.mns-notification-alarm-topic.arn]
}

module "mns-notification-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "mns-notification-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.mns-notification-lambda.lambda_arn
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

resource "aws_iam_policy" "kms_lambda_access" {
  name        = "mns_notification_lambda_access_policy"
  description = "KMS policy to allow lambda to read MNS SQS messages"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
        ]
        Effect   = "Allow"
        Resource = module.mns_encryption_key.kms_arn
      },
    ]
  })
}