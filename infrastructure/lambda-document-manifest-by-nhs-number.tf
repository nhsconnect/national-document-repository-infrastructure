module "document-manifest-by-nhs-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["GET", "POST"]
  authorization       = "CUSTOM"
  gateway_path        = "DocumentManifest"
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

module "document_manifest_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.document-manifest-by-nhs-number-lambda.function_name
  lambda_timeout       = module.document-manifest-by-nhs-number-lambda.timeout
  lambda_name          = "create_document_manifest_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.document_manifest_alarm_topic.arn]
  ok_actions           = [module.document_manifest_alarm_topic.arn]
  depends_on           = [module.document-manifest-by-nhs-number-lambda, module.document_manifest_alarm_topic]
}


module "document_manifest_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "create_doc_manifest-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.document-manifest-by-nhs-number-lambda.lambda_arn
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

module "document-manifest-lambda" {
  source         = "./modules/lambda"
  name           = "DocumentManifestLambda"
  handler        = "handlers.document_manifest_handler.lambda_handler"
  lambda_timeout = 900
  iam_role_policies = [
    module.document_reference_dynamodb_table.dynamodb_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    module.zip_store_reference_dynamodb_table.dynamodb_policy,
    module.ndr-zip-request-store.s3_object_access_policy,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    module.ndr-app-config.app_config_policy_arn
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.document-manifest-by-nhs-gateway.gateway_resource_id
  http_methods      = ["GET", "POST"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION        = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT        = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION      = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME   = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    ZIPPED_STORE_BUCKET_NAME     = "${terraform.workspace}-${var.zip_store_bucket_name}"
    ZIPPED_STORE_DYNAMODB_NAME   = "${terraform.workspace}_${var.zip_store_dynamodb_table_name}"
    SPLUNK_SQS_QUEUE_URL         = try(module.sqs-splunk-queue[0].sqs_url, null)
    WORKSPACE                    = terraform.workspace
    PRESIGNED_ASSUME_ROLE        = aws_iam_role.manifest_presign_url_role.arn
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.document-manifest-by-nhs-gateway,
    aws_iam_policy.lambda_audit_splunk_sqs_queue_send_policy[0],
    module.ndr-app-config,
    module.lloyd_george_reference_dynamodb_table,
    module.document_reference_dynamodb_table,
    module.zip_store_reference_dynamodb_table,
    module.ndr-zip-request-store
  ]
}

resource "aws_iam_role_policy_attachment" "policy_manifest_lambda" {
  count      = local.is_sandbox ? 0 : 1
  role       = module.document-manifest-by-nhs-number-lambda.lambda_execution_role_name
  policy_arn = try(aws_iam_policy.lambda_audit_splunk_sqs_queue_send_policy[0].arn, null)
}
