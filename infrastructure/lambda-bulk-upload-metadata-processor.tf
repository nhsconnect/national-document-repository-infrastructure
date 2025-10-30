module "bulk-upload-metadata-processor-lambda" {
  source         = "./modules/lambda"
  name           = "BulkUploadMetadataProcessor"
  handler        = "handlers.bulk_upload_metadata_processor_handler.lambda_handler"
  lambda_timeout = 900
  memory_size    = 1769
  iam_role_policy_documents = [
    module.ndr-bulk-staging-store.s3_read_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.bulk_upload_report_dynamodb_table.dynamodb_read_policy_document,
    module.bulk_upload_report_dynamodb_table.dynamodb_write_policy_document,
    module.sqs-lg-bulk-upload-metadata-queue.sqs_read_policy_document,
    module.sqs-lg-bulk-upload-metadata-queue.sqs_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]

  rest_api_id       = null
  api_execution_arn = null

  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    STAGING_STORE_BUCKET_NAME  = "${terraform.workspace}-${var.staging_store_bucket_name}"
    BULK_UPLOAD_DYNAMODB_NAME  = "${terraform.workspace}_${var.bulk_upload_report_dynamodb_table_name}"
    LLOYD_GEORGE_BUCKET_NAME   = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    METADATA_SQS_QUEUE_URL     = module.sqs-lg-bulk-upload-metadata-queue.sqs_url
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
}

module "bulk-upload-metadata-processor-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.bulk-upload-metadata-processor-lambda.function_name
  lambda_timeout       = module.bulk-upload-metadata-processor-lambda.timeout
  lambda_name          = "bulk_upload_metadata_processor_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.bulk-upload-metadata-processor-alarm-topic.arn]
  ok_actions           = [module.bulk-upload-metadata-processor-alarm-topic.arn]
  depends_on           = [module.bulk-upload-metadata-processor-lambda, module.bulk-upload-metadata-processor-alarm-topic]
}

module "bulk-upload-metadata-processor-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "bulk-upload-metadata-processor-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.bulk-upload-metadata-processor-lambda.lambda_arn
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

  depends_on = [module.bulk-upload-metadata-processor-lambda, module.sns_encryption_key]
}

resource "aws_lambda_permission" "bulk_upload_metadata_processor_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.bulk-upload-metadata-processor-lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.ndr-bulk-staging-store.bucket_arn
}

resource "aws_s3_bucket_notification" "bulk_upload_metadata_processor_lambda_trigger" {
  bucket = module.ndr-bulk-staging-store.bucket_id

  lambda_function {
    lambda_function_arn = module.bulk-upload-metadata-processor-lambda.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "expedite/"
    filter_suffix       = ".pdf"
  }

  depends_on = [
    aws_lambda_permission.bulk_upload_metadata_processor_lambda
  ]
}
