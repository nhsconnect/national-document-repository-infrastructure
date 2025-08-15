module "bulk-upload-report-lambda" {
  source         = "./modules/lambda"
  name           = "BulkUploadReportLambda"
  handler        = "handlers.bulk_upload_report_handler.lambda_handler"
  lambda_timeout = 900
  memory_size    = 1769
  iam_role_policy_documents = [
    module.statistical-reports-store.s3_read_policy_document,
    module.statistical-reports-store.s3_write_policy_document,
    module.bulk_upload_report_dynamodb_table.dynamodb_read_policy_document,
    module.bulk_upload_report_dynamodb_table.dynamodb_write_policy_document,
    aws_iam_policy.dynamodb_policy_scan_bulk_report.policy,
    module.ndr-app-config.app_config_policy
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = null
  api_execution_arn   = null

  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    STATISTICAL_REPORTS_BUCKET = "${terraform.workspace}-${var.statistical_reports_bucket_name}"
    BULK_UPLOAD_DYNAMODB_NAME  = "${terraform.workspace}_${var.bulk_upload_report_dynamodb_table_name}"
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
}

resource "aws_iam_policy" "dynamodb_policy_scan_bulk_report" {
  name = "${terraform.workspace}_${var.bulk_upload_report_dynamodb_table_name}_scan_policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:Scan",
        ],
        "Resource" : [
          module.bulk_upload_report_dynamodb_table.dynamodb_table_arn,
        ]
      }
    ]
  })
}

module "bulk-upload-report-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.bulk-upload-report-lambda.function_name
  lambda_timeout       = module.bulk-upload-report-lambda.timeout
  lambda_name          = "bulk_upload_report_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.bulk-upload-report-alarm-topic.arn]
  ok_actions           = [module.bulk-upload-report-alarm-topic.arn]
  depends_on           = [module.bulk-upload-report-lambda, module.bulk-upload-report-alarm-topic]
}

module "bulk-upload-report-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "bulk-upload-report-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.bulk-upload-report-lambda.lambda_arn
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

  depends_on = [module.bulk-upload-report-lambda, module.sns_encryption_key]
}
