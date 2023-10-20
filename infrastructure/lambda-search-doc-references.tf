module "search-document-references-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_method         = "GET"
  authorization       = "CUSTOM"
  gateway_path        = "SearchDocumentReferences"
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

module "search_doc_alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.search-document-references-lambda.function_name
  lambda_timeout       = module.search-document-references-lambda.timeout
  lambda_name          = "search_document_references_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.search_doc_alarm_topic.arn]
  ok_actions           = [module.search_doc_alarm_topic.arn]
  depends_on           = [module.search-document-references-lambda, module.search_doc_alarm_topic]
}


module "search_doc_alarm_topic" {
  source         = "./modules/sns"
  topic_name     = "search_doc_references-alarms-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.search-document-references-lambda.endpoint
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


module "search-document-references-lambda" {
  source  = "./modules/lambda"
  name    = "SearchDocumentReferencesLambda"
  handler = "handlers.document_reference_search_handler.lambda_handler"
  iam_role_policies = [
    module.document_reference_dynamodb_table.dynamodb_policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.search-document-references-gateway.gateway_resource_id
  http_method       = "GET"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    DYNAMODB_TABLE_LIST = "[\u0022${terraform.workspace}_${var.docstore_dynamodb_table_name}\u0022, \u0022${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}\u0022]"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.search-document-references-gateway
  ]
}
