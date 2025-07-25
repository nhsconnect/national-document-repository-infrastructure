module "statistical-report-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.statistical-report-lambda.function_name
  lambda_timeout       = module.statistical-report-lambda.timeout
  lambda_name          = "statistical_report_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.statistical-report-alarm-topic.arn]
  ok_actions           = [module.statistical-report-alarm-topic.arn]
  depends_on           = [module.statistical-report-lambda, module.statistical-report-alarm-topic]
}

module "statistical-report-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "statistical-report-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.statistical-report-lambda.lambda_arn
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

  depends_on = [module.statistical-report-lambda, module.sns_encryption_key]
}

module "statistical-report-lambda" {
  source                   = "./modules/lambda"
  name                     = "StatisticalReportLambda"
  handler                  = "handlers.statistical_report_handler.lambda_handler"
  lambda_timeout           = 900
  lambda_ephemeral_storage = local.is_production ? 10240 : 1769
  memory_size              = local.is_production ? 10240 : 1769
  iam_role_policy_documents = [
    module.ndr-app-config.app_config_policy,
    module.statistics_dynamodb_table.dynamodb_read_policy_document,
    module.statistics_dynamodb_table.dynamodb_write_policy_document,
    module.statistical-reports-store.s3_read_policy_document,
    module.statistical-reports-store.s3_write_policy_document,
    aws_iam_policy.cloudwatch_log_query_policy.policy
  ]
  rest_api_id       = null
  api_execution_arn = null

  lambda_environment_variables = {
    APPCONFIG_APPLICATION      = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT      = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION    = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                  = terraform.workspace
    STATISTICS_TABLE           = "${terraform.workspace}_${var.statistics_dynamodb_table_name}"
    STATISTICAL_REPORTS_BUCKET = "${terraform.workspace}-${var.statistical_reports_bucket_name}"
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false

  depends_on = [
    module.ndr-app-config,
    module.statistics_dynamodb_table,
    module.statistical-reports-store,
    aws_iam_policy.cloudwatch_log_query_policy
  ]
}
