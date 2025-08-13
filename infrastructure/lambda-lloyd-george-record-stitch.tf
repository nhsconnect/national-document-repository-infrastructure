module "lloyd-george-stitch-gateway" {
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["GET", "POST"]
  authorization       = "CUSTOM"
  gateway_path        = "LloydGeorgeStitch"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"
}

module "lloyd-george-stitch_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.lloyd-george-stitch-lambda.function_name
  lambda_timeout       = module.lloyd-george-stitch-lambda.timeout
  lambda_name          = "lloyd_george_record_stitch_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.lloyd-george-stitch_topic.arn]
  ok_actions           = [module.lloyd-george-stitch_topic.arn]
  depends_on           = [module.lloyd-george-stitch-lambda, module.lloyd-george-stitch_topic]
}


module "lloyd-george-stitch_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "lloyd-george-stitch-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.lloyd-george-stitch-lambda.lambda_arn
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

module "lloyd-george-stitch-lambda" {
  source  = "./modules/lambda"
  name    = "LloydGeorgeStitchLambda"
  handler = "handlers.lloyd_george_record_stitch_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-lloyd-george-store.s3_read_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy,
    module.stitch_metadata_reference_dynamodb_table.dynamodb_read_policy_document,
    module.stitch_metadata_reference_dynamodb_table.dynamodb_write_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.cloudfront_edge_dynamodb_table.dynamodb_write_policy_document
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.lloyd-george-stitch-gateway.gateway_resource_id
  http_methods      = ["GET", "POST"]
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_timeout    = 450
  lambda_environment_variables = {
    APPCONFIG_APPLICATION         = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT         = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION       = module.ndr-app-config.app_config_configuration_profile_id
    LLOYD_GEORGE_BUCKET_NAME      = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    LLOYD_GEORGE_DYNAMODB_NAME    = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    STITCH_METADATA_DYNAMODB_NAME = "${terraform.workspace}_${var.stitch_metadata_dynamodb_table_name}"
    CLOUDFRONT_URL                = module.cloudfront-distribution-lg.cloudfront_url
    WORKSPACE                     = terraform.workspace
    PRESIGNED_ASSUME_ROLE         = aws_iam_role.stitch_presign_url_role.arn
    EDGE_REFERENCE_TABLE          = module.cloudfront_edge_dynamodb_table.table_name
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.ndr-lloyd-george-store,
    module.lloyd-george-stitch-gateway,
    module.ndr-app-config,
    module.cloudfront-distribution-lg,
    module.stitch_metadata_reference_dynamodb_table,
    module.lloyd_george_reference_dynamodb_table
  ]
}
