module "update_doc_ref_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.update_doc_ref_lambda.function_name
  lambda_timeout       = module.update_doc_ref_lambda.timeout
  lambda_name          = "update_document_reference_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.update_doc_ref_alarm_topic.arn]
  ok_actions           = [module.update_doc_ref_alarm_topic.arn]
  depends_on           = [module.update_doc_ref_lambda, module.update_doc_ref_alarm_topic]
}


module "update_doc_ref_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "update_doc-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.update_doc_ref_lambda.lambda_arn
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

module "update_doc_ref_lambda" {
  source  = "./modules/lambda"
  name    = "UpdateDocRefLambda"
  handler = "handlers.update_document_reference_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-document-store.s3_read_policy_document,
    module.ndr-document-store.s3_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    aws_iam_policy.ssm_access_policy.policy,
    module.ndr-app-config.app_config_policy,
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id         = module.document_reference_id_gateway.gateway_resource_id.id
  http_methods        = ["PUT"]
  memory_size         = 512

  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    STAGING_STORE_BUCKET_NAME     = module.ndr-bulk-staging-store.bucket_id
    APPCONFIG_APPLICATION         = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT         = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION       = module.ndr-app-config.app_config_configuration_profile_id
    DOCUMENT_STORE_BUCKET_NAME    = module.ndr-document-store.bucket_id
    DOCUMENT_STORE_DYNAMODB_NAME  = module.document_reference_dynamodb_table.table_name
    LLOYD_GEORGE_DYNAMODB_NAME    = module.lloyd_george_reference_dynamodb_table.table_name
    STITCH_METADATA_DYNAMODB_NAME = module.stitch_metadata_reference_dynamodb_table.table_name
    PDS_FHIR_IS_STUBBED           = local.is_sandbox,
    WORKSPACE                     = terraform.workspace
    PRESIGNED_ASSUME_ROLE         = aws_iam_role.update_put_presign_url_role.arn
  }
  depends_on = [
    module.document_reference_gateway,
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.document_reference_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table,
    module.ndr-bulk-staging-store,
    module.ndr-document-store,
    module.ndr-app-config,
    module.stitch_metadata_reference_dynamodb_table
  ]
}
