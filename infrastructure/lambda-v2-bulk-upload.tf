module "v2-bulk-upload-lambda" {
  count   = local.is_sandbox || (terraform.workspace == "ndr-dev") ? 1 : 0
  source  = "./modules/lambda"
  name    = "V2BulkUploadLambda"
  handler = "handlers.bulk_upload_handler.lambda_handler"

  iam_role_policy_documents = [
    module.ndr-bulk-staging-store.s3_read_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.bulk_upload_report_dynamodb_table.dynamodb_read_policy_document,
    module.bulk_upload_report_dynamodb_table.dynamodb_write_policy_document,
    module.sqs-stitching-queue.sqs_write_policy_document,
    module.v2-sqs-lg-bulk-upload-metadata-queue[0].sqs_read_policy_document,
    module.v2-sqs-lg-bulk-upload-metadata-queue[0].sqs_write_policy_document,
    module.v2-sqs-lg-bulk-upload-invalid-queue[0].sqs_read_policy_document,
    module.v2-sqs-lg-bulk-upload-invalid-queue[0].sqs_write_policy_document,
    aws_iam_policy.ssm_access_policy.policy,
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
    LLOYD_GEORGE_BUCKET_NAME   = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    BULK_UPLOAD_DYNAMODB_NAME  = "${terraform.workspace}_${var.bulk_upload_report_dynamodb_table_name}"
    METADATA_SQS_QUEUE_URL     = module.v2-sqs-lg-bulk-upload-metadata-queue[0].sqs_url
    INVALID_SQS_QUEUE_URL      = module.v2-sqs-lg-bulk-upload-invalid-queue[0].sqs_url
    PDS_FHIR_IS_STUBBED        = local.is_sandbox
    PDF_STITCHING_SQS_URL      = module.sqs-stitching-queue.sqs_url
    APIM_API_URL               = data.aws_ssm_parameter.apim_url.value
  }

  is_gateway_integration_needed  = false
  is_invoked_from_gateway        = false
  lambda_timeout                 = 900
  reserved_concurrent_executions = local.bulk_upload_lambda_concurrent_limit

  depends_on = [
    module.ndr-bulk-staging-store,
    module.v2-sqs-lg-bulk-upload-metadata-queue[0],
    module.v2-sqs-lg-bulk-upload-invalid-queue[0],
    module.ndr-lloyd-george-store,
    module.lloyd_george_reference_dynamodb_table,
    module.bulk_upload_report_dynamodb_table,
    aws_iam_policy.ssm_access_policy,
  ]
}

resource "aws_lambda_event_source_mapping" "v2_bulk_upload_lambda" {
  event_source_arn = module.v2-sqs-lg-bulk-upload-metadata-queue[0].sqs_arn
  function_name    = module.v2-bulk-upload-lambda[0].lambda_arn
  enabled          = local.is_sandbox ? true : false # Disabled by default; scheduler lambda will control
  batch_size       = 10
  scaling_config {
    maximum_concurrency = local.bulk_upload_lambda_concurrent_limit
  }

  depends_on = [
    module.v2-bulk-upload-lambda[0],
    module.v2-sqs-lg-bulk-upload-metadata-queue[0]
  ]
}

module "v2-bulk-upload-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.v2-bulk-upload-lambda[0].function_name
  lambda_timeout       = module.v2-bulk-upload-lambda[0].timeout
  lambda_name          = "bulk_upload_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.v2-bulk-upload-alarm-topic.arn]
  ok_actions           = [module.v2-bulk-upload-alarm-topic.arn]
  depends_on           = [module.v2-bulk-upload-lambda[0], module.v2-bulk-upload-alarm-topic]
}

module "v2-bulk-upload-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "v2-bulk-upload-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.v2-bulk-upload-lambda[0].lambda_arn
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

  depends_on = [module.v2-bulk-upload-lambda[0], module.sns_encryption_key]
}
