module "create_document_reference_gateway" {
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["POST"]
  authorization       = "CUSTOM"
  gateway_path        = "CreateDocumentReference"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
}

module "create_doc_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.create-doc-ref-lambda.function_name
  lambda_timeout       = module.create-doc-ref-lambda.timeout
  lambda_name          = "create_document_reference_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.create_doc_alarm_topic.arn]
  ok_actions           = [module.create_doc_alarm_topic.arn]
  depends_on           = [module.create-doc-ref-lambda, module.create_doc_alarm_topic]
}


module "create_doc_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "create_doc-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.create-doc-ref-lambda.lambda_arn
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

module "create-doc-ref-lambda" {
  source  = "./modules/lambda"
  name    = "CreateDocRefLambda"
  handler = "handlers.create_document_reference_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-bulk-staging-store.s3_read_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-document-store.s3_read_policy_document,
    module.ndr-document-store.s3_write_policy_document,
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    module.document_reference_dynamodb_table.dynamodb_read_policy_document,
    module.stitch_metadata_reference_dynamodb_table.dynamodb_read_policy_document,
    module.stitch_metadata_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    aws_iam_policy.ssm_access_policy.policy,
    module.ndr-app-config.app_config_policy,
  ]
  kms_deletion_window = var.kms_deletion_window
  account_id          = data.aws_caller_identity.current.account_id
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = module.create_document_reference_gateway.gateway_resource_id
  http_methods        = ["POST"]
  memory_size         = 512

  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    STAGING_STORE_BUCKET_NAME     = "${terraform.workspace}-${var.staging_store_bucket_name}"
    APPCONFIG_APPLICATION         = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT         = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION       = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_BUCKET_NAME    = "${terraform.workspace}-${var.docstore_bucket_name}"
    DOCUMENT_STORE_DYNAMODB_NAME  = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME    = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    STITCH_METADATA_DYNAMODB_NAME = "${terraform.workspace}_${var.stitch_metadata_dynamodb_table_name}"
    PDS_FHIR_IS_STUBBED           = local.is_sandbox,
    WORKSPACE                     = terraform.workspace
    PRESIGNED_ASSUME_ROLE         = aws_iam_role.create_post_presign_url_role.arn
  }
  depends_on = [
    module.create_document_reference_gateway,
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.document_reference_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table,
    module.ndr-bulk-staging-store,
    module.ndr-app-config,
    module.lloyd_george_reference_dynamodb_table,
    module.document_reference_dynamodb_table,
    module.stitch_metadata_reference_dynamodb_table
  ]
}
