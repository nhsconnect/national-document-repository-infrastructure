module "delete-doc-ref-gateway" {
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["DELETE"]
  authorization       = "CUSTOM"
  gateway_path        = "DocumentDelete"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
}

module "delete_doc_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.delete-doc-ref-lambda.function_name
  lambda_timeout       = module.delete-doc-ref-lambda.timeout
  lambda_name          = "delete_document_reference_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.delete_doc_alarm_topic.arn]
  ok_actions           = [module.delete_doc_alarm_topic.arn]
  depends_on           = [module.delete-doc-ref-lambda, module.delete_doc_alarm_topic]
}

module "delete_doc_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "delete_doc-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.delete-doc-ref-lambda.lambda_arn
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

module "delete-doc-ref-lambda" {
  source  = "./modules/lambda"
  name    = "DeleteDocRefLambda"
  handler = "handlers.delete_document_reference_handler.lambda_handler"
  iam_role_policy_documents = [
    module.document_reference_dynamodb_table.dynamodb_read_policy_document,
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-document-store.s3_read_policy_document,
    module.ndr-document-store.s3_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy,
    module.stitch_metadata_reference_dynamodb_table.dynamodb_read_policy_document,
    module.stitch_metadata_reference_dynamodb_table.dynamodb_write_policy_document,
    module.sqs-nrl-queue.sqs_read_policy_document,
    module.sqs-nrl-queue.sqs_write_policy_document,
    module.unstitched_lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.unstitched_lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.delete-doc-ref-gateway.gateway_resource_id
  http_methods      = ["DELETE"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION                 = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT                 = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION               = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_DYNAMODB_NAME          = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME            = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    STITCH_METADATA_DYNAMODB_NAME         = "${terraform.workspace}_${var.stitch_metadata_dynamodb_table_name}"
    UNSTITCHED_LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.unstitched_lloyd_george_dynamodb_table_name}"
    WORKSPACE                             = terraform.workspace
    NRL_SQS_QUEUE_URL                     = module.sqs-nrl-queue.sqs_url
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.document_reference_dynamodb_table,
    module.stitch_metadata_reference_dynamodb_table,
    module.delete-doc-ref-gateway,
    module.ndr-app-config
  ]
}
