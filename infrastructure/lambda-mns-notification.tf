module "mns-notification-lambda" {
  count   = 1
  source  = "./modules/lambda"
  name    = "MNSNotificationLambda"
  handler = "handlers.mns_notification_handler.lambda_handler"
  iam_role_policy_documents = [
    module.sqs-mns-notification-queue[0].sqs_read_policy_document,
    module.sqs-mns-notification-queue[0].sqs_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    aws_iam_policy.ssm_access_policy.policy,
    module.ndr-app-config.app_config_policy,
    aws_iam_policy.kms_mns_lambda_access[0].policy,
  ]
  kms_deletion_window = var.kms_deletion_window
  account_id          = data.aws_caller_identity.current.account_id
  rest_api_id         = null
  api_execution_arn   = null
  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    MNS_NOTIFICATION_QUEUE_URL = module.sqs-mns-notification-queue[0].sqs_url
    PDS_FHIR_IS_STUBBED        = local.is_sandbox
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
  lambda_timeout                = 900
}

resource "aws_lambda_event_source_mapping" "mns_notification_lambda" {
  count            = 1
  event_source_arn = module.sqs-mns-notification-queue[0].endpoint
  function_name    = module.mns-notification-lambda[0].lambda_arn
}

module "mns-notification-alarm" {
  count                = 1
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.mns-notification-lambda[0].function_name
  lambda_timeout       = module.mns-notification-lambda[0].timeout
  lambda_name          = "mns_notification_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.mns-notification-alarm-topic[0].arn]
  ok_actions           = [module.mns-notification-alarm-topic[0].arn]
}

module "mns-notification-alarm-topic" {
  count                 = 1
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "mns-notification-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.mns-notification-lambda[0].lambda_arn
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

resource "aws_iam_policy" "kms_mns_lambda_access" {
  count = 1

  name        = "${terraform.workspace}_mns_notification_lambda_access_policy"
  description = "KMS policy to allow lambda to read and write MNS SQS messages"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Effect   = "Allow"
        Resource = module.mns_encryption_key[0].kms_arn
      },
    ]
  })
}
