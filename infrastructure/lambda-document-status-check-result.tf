module "document-status-check-gateway" {
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["GET"]
  authorization       = "CUSTOM"
  gateway_path        = "DocumentStatus"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
}

module "document-status-check-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.document-status-check-lambda.function_name
  lambda_timeout       = module.document-status-check-lambda.timeout
  lambda_name          = "document_status_check_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.document-status-check-alarm-topic.arn]
  ok_actions           = [module.document-status-check-alarm-topic.arn]
  depends_on           = [module.document-status-check-lambda, module.document-status-check-alarm-topic]
}


module "document-status-check-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "document-status-check-alarm-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.document-status-check-lambda.lambda_arn
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

module "document-status-check-lambda" {
  source  = "./modules/lambda"
  name    = "DocumentStatusCheckLambda"
  handler = "handlers.document_status_check_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-app-config.app_config_policy,
    aws_iam_policy.ssm_access_policy.policy,
    module.document_reference_dynamodb_table.dynamodb_read_policy_document,
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = module.document-status-check-gateway.gateway_resource_id
  http_methods        = ["GET"]
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION        = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT        = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION      = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME   = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    WORKSPACE                    = terraform.workspace
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.ndr-bulk-staging-store,
    module.document-status-check-gateway,
    module.ndr-app-config,
    module.lloyd_george_reference_dynamodb_table,
    module.document_reference_dynamodb_table,
  ]
}
