module "virus_scan_result_gateway" {
  count = local.is_production ? 0 : 1
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_method         = "POST"
  authorization       = "CUSTOM"
  gateway_path        = "VirusScan"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = "'https://${terraform.workspace}.${var.domain}'"

  # Lambda Variables
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  owner             = var.owner
  environment       = var.environment

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
  ]
}

module "virus_scan_result_alarm" {
  count                = local.is_production ? 0 : 1
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.virus_scan_result_lambda[0].function_name
  lambda_timeout       = module.virus_scan_result_lambda[0].timeout
  lambda_name          = "virus_scan_result_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.virus_scan_result_alarm_topic[0].arn]
  ok_actions           = [module.virus_scan_result_alarm_topic[0].arn]
  depends_on           = [module.virus_scan_result_lambda[0], module.virus_scan_result_alarm_topic[0]]
}


module "virus_scan_result_alarm_topic" {
  count                 = local.is_production ? 0 : 1
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "virus_scan_result_alarm-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.virus_scan_result_lambda[0].endpoint
  depends_on            = [module.sns_encryption_key]
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

module "virus_scan_result_lambda" {
  count       = local.is_production ? 0 : 1
  source      = "./modules/lambda"
  name        = "VirusScanResult"
  handler     = "handlers.virus_scan_result_handler.lambda_handler"
  memory_size = 256
  iam_role_policies = [
    module.ndr-bulk-staging-store.s3_object_access_policy,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    module.ndr-app-config.app_config_policy_arn,
    aws_iam_policy.ssm_access_policy.arn,
    module.document_reference_dynamodb_table.dynamodb_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.virus_scan_result_gateway[0].gateway_resource_id
  http_method       = "POST"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION        = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT        = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION      = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME   = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    STAGING_STORE_BUCKET_NAME    = "${terraform.workspace}-${var.staging_store_bucket_name}"
    WORKSPACE                    = terraform.workspace
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.ndr-bulk-staging-store,
    module.virus_scan_result_gateway[0],
    module.ndr-app-config,
    module.document_reference_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table,
  ]
}
