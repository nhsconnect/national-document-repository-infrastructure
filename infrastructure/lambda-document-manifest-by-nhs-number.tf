module "document-manifest-by-nhs-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_method         = "GET"
  authorization       = "CUSTOM"
  gateway_path        = "DocumentManifest"
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

module "document_manifest_alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.document-manifest-by-nhs-number-lambda.function_name
  lambda_timeout       = module.document-manifest-by-nhs-number-lambda.timeout
  lambda_name          = "create_document_manifest_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.document_manifest_alarm_topic.arn]
  ok_actions           = [module.document_manifest_alarm_topic.arn]
  depends_on           = [module.document-manifest-by-nhs-number-lambda, module.document_manifest_alarm_topic]
}


module "document_manifest_alarm_topic" {
  source         = "./modules/sns"
  topic_name     = "create_doc_manifest-alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.document-manifest-by-nhs-number-lambda.endpoint
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

module "document-manifest-by-nhs-number-lambda" {
  source                   = "./modules/lambda"
  name                     = "DocumentManifestByNHSNumberLambda"
  handler                  = "handlers.document_manifest_by_nhs_number_handler.lambda_handler"
  lambda_timeout           = 900
  lambda_ephemeral_storage = 512
  iam_role_policies = [
    module.document_reference_dynamodb_table.dynamodb_policy,
    module.ndr-document-store.s3_object_access_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    module.ndr-lloyd-george-store.s3_object_access_policy,
    module.zip_store_reference_dynamodb_table.dynamodb_policy,
    module.ndr-zip-request-store.s3_object_access_policy,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.document-manifest-by-nhs-gateway.gateway_resource_id
  http_method       = "GET"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    DOCUMENT_STORE_BUCKET_NAME   = "${terraform.workspace}-${var.docstore_bucket_name}"
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_BUCKET_NAME     = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    LLOYD_GEORGE_DYNAMODB_NAME   = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    ZIPPED_STORE_BUCKET_NAME     = "${terraform.workspace}-${var.zip_store_bucket_name}"
    ZIPPED_STORE_DYNAMODB_NAME   = "${terraform.workspace}_${var.zip_store_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.document-manifest-by-nhs-gateway,
  ]
}
