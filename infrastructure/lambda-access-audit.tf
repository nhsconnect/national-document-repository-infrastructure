module "access-audit-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["POST"]
  authorization       = "CUSTOM"
  gateway_path        = "AccessAudit"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"

  # Lambda Variables
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  owner             = var.owner
  environment       = var.environment

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
  ]
}

module "access-audit-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.access-audit-lambda.function_name
  lambda_timeout       = module.access-audit-lambda.timeout
  lambda_name          = "access_audit_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.access-audit-alarm-topic.arn]
  ok_actions           = [module.access-audit-alarm-topic.arn]
  depends_on           = [module.access-audit-lambda, module.access-audit-alarm-topic]
}


module "access-audit-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "access-audit-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.access-audit-lambda.lambda_arn
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

module "access-audit-lambda" {
  source  = "./modules/lambda"
  name    = "AccessAuditLambda"
  handler = "handlers.access_audit_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-app-config.app_config_policy,
    module.auth_session_dynamodb_table.dynamodb_write_policy_document,
    module.auth_session_dynamodb_table.dynamodb_read_policy_document,
    module.access_audit_dynamodb_table.dynamodb_write_without_update_policy_document
  ]
  rest_api_id  = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id  = module.access-audit-gateway.gateway_resource_id
  http_methods = ["POST"]
  memory_size  = 512

  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION   = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT   = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE               = terraform.workspace
    AUTH_SESSION_TABLE_NAME = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
    ACCESS_AUDIT_TABLE_NAME = "${terraform.workspace}_${var.access_audit_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
  ]
}
