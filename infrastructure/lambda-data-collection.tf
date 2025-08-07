module "data-collection-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.data-collection-lambda.function_name
  lambda_timeout       = module.data-collection-lambda.timeout
  lambda_name          = "data_collection_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.data-collection-alarm-topic.arn]
  ok_actions           = [module.data-collection-alarm-topic.arn]
  depends_on           = [module.data-collection-lambda, module.data-collection-alarm-topic]
}

module "data-collection-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "data-collection-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.data-collection-lambda.lambda_arn
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

  depends_on = [module.data-collection-lambda, module.sns_encryption_key]
}

module "data-collection-lambda" {
  source                   = "./modules/lambda"
  name                     = "DataCollectionLambda"
  handler                  = "handlers.data_collection_handler.lambda_handler"
  lambda_timeout           = 900
  lambda_ephemeral_storage = local.is_production ? 10240 : 1769
  memory_size              = local.is_production ? 10240 : 1769
  iam_role_policy_documents = [
    module.ndr-app-config.app_config_policy,
    module.statistics_dynamodb_table.dynamodb_read_policy_document,
    module.statistics_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-document-store.s3_read_policy_document,
    module.ndr-document-store.s3_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.document_reference_dynamodb_table.dynamodb_read_policy_document,
    module.document_reference_dynamodb_table.dynamodb_write_policy_document,
    aws_iam_policy.cloudwatch_log_query_policy.policy
  ]
  kms_deletion_window = var.kms_deletion_window
  account_id          = data.aws_caller_identity.current.account_id
  rest_api_id         = null
  api_execution_arn   = null

  lambda_environment_variables = {
    APPCONFIG_APPLICATION        = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT        = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION      = module.ndr-app-config.app_config_configuration_profile_id
    LLOYD_GEORGE_BUCKET_NAME     = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    LLOYD_GEORGE_DYNAMODB_NAME   = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    DOCUMENT_STORE_BUCKET_NAME   = "${terraform.workspace}-${var.docstore_bucket_name}"
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    WORKSPACE                    = terraform.workspace
    STATISTICS_TABLE             = "${terraform.workspace}_${var.statistics_dynamodb_table_name}"
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false

  depends_on = [
    module.ndr-app-config,
    module.statistics_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table,
    module.document_reference_dynamodb_table,
    module.ndr-document-store,
    module.ndr-lloyd-george-store,
    aws_iam_policy.cloudwatch_log_query_policy
  ]
}


resource "aws_iam_policy" "cloudwatch_log_query_policy" {
  name = "${terraform.workspace}_cloudwatch_log_query_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:StartQuery",
          "logs:GetQueryResults",
        ],
        "Resource" : ["arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:*"]
      }
    ]
  })
}
