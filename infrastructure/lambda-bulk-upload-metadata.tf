module "bulk-upload-metadata-lambda" {
  source         = "./modules/lambda"
  name           = "BulkUploadMetadataLambda"
  handler        = "handlers.bulk_upload_metadata_handler.lambda_handler"
  lambda_timeout = 900
  iam_role_policy_documents = [
    module.ndr-bulk-staging-store.s3_read_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.sqs-lg-bulk-upload-metadata-queue.sqs_read_policy_document,
    module.sqs-lg-bulk-upload-metadata-queue.sqs_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]

  rest_api_id       = null
  api_execution_arn = null

  lambda_environment_variables = {
    APPCONFIG_APPLICATION     = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT     = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION   = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                 = terraform.workspace
    STAGING_STORE_BUCKET_NAME = "${terraform.workspace}-${var.staging_store_bucket_name}"
    METADATA_SQS_QUEUE_URL    = module.sqs-lg-bulk-upload-metadata-queue.sqs_url
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false

  depends_on = [
    module.ndr-bulk-staging-store,
    module.sqs-lg-bulk-upload-metadata-queue,
    module.ndr-app-config
  ]
}

module "bulk-upload-metadata-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.bulk-upload-metadata-lambda.function_name
  lambda_timeout       = module.bulk-upload-metadata-lambda.timeout
  lambda_name          = "bulk_upload_metadata_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.bulk-upload-metadata-alarm-topic.arn]
  ok_actions           = [module.bulk-upload-metadata-alarm-topic.arn]
  depends_on           = [module.bulk-upload-metadata-lambda, module.bulk-upload-metadata-alarm-topic]
}

module "bulk-upload-metadata-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "bulk-upload-metadata-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.bulk-upload-metadata-lambda.lambda_arn
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

  depends_on = [module.bulk-upload-metadata-lambda, module.sns_encryption_key]
}