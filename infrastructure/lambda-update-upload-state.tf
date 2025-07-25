module "update-upload-state-gateway" {
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["POST"]
  authorization       = "CUSTOM"
  gateway_path        = "UploadState"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
}

module "update_upload_state_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.update-upload-state-lambda.function_name
  lambda_timeout       = module.update-upload-state-lambda.timeout
  lambda_name          = "update_upload_state_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.update_upload_state_alarm_topic.arn]
  ok_actions           = [module.update_upload_state_alarm_topic.arn]
  depends_on           = [module.update-upload-state-lambda, module.update_upload_state_alarm_topic]
}


module "update_upload_state_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "update-upload-state-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.update-upload-state-lambda.lambda_arn
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

  depends_on = [module.update-upload-state-lambda, module.sns_encryption_key]
}
module "update-upload-state-lambda" {
  source  = "./modules/lambda"
  name    = "UpdateUploadStateLambda"
  handler = "handlers.update_upload_state_handler.lambda_handler"
  iam_role_policy_documents = [
    module.document_reference_dynamodb_table.dynamodb_read_policy_document,
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-app-config.app_config_policy,
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.update-upload-state-gateway.gateway_resource_id
  http_methods      = ["POST"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION        = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT        = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION      = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME   = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    WORKSPACE                    = terraform.workspace,
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.update-upload-state-gateway,
    module.ndr-app-config,
    module.document_reference_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table,
  ]
}
