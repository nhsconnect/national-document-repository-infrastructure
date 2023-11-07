module "delete-doc-ref-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_method         = "DELETE"
  authorization       = "CUSTOM"
  gateway_path        = "DocumentDelete"
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
  source         = "./modules/sns"
  topic_name     = "delete_doc-alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.delete-doc-ref-lambda.endpoint
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
  iam_role_policies = [
    module.document_reference_dynamodb_table.dynamodb_policy,
    module.ndr-document-store.s3_object_access_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    module.ndr-lloyd-george-store.s3_object_access_policy,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.delete-doc-ref-gateway.gateway_resource_id
  http_method       = "DELETE"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_${var.docstore_dynamodb_table_name}"
    LLOYD_GEORGE_DYNAMODB_NAME   = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.document_reference_dynamodb_table,
    module.delete-doc-ref-gateway
  ]
}