module "lloyd-george-stitch-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_method         = "GET"
  authorization       = "CUSTOM"
  gateway_path        = "LloydGeorgeStitch"
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

module "lloyd-george-stitch_alarm" {
  source               = "./modules/alarm"
  lambda_function_name = module.lloyd-george-stitch-lambda.function_name
  lambda_timeout       = module.lloyd-george-stitch-lambda.timeout
  lambda_name          = "lloyd_george_record_stitch_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.lloyd-george-stitch_topic.arn]
  ok_actions           = [module.lloyd-george-stitch_topic.arn]
  depends_on           = [module.lloyd-george-stitch-lambda, module.lloyd-george-stitch_topic]
}


module "lloyd-george-stitch_topic" {
  source         = "./modules/sns"
  topic_name     = "lloyd-george-stitch-topic"
  topic_protocol = "lambda"
  topic_endpoint = module.lloyd-george-stitch-lambda.endpoint
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
  iam_role_policies = [
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
    module.ndr-lloyd-george-store.s3_object_access_policy,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.lloyd-george-stitch-gateway.gateway_resource_id
  http_method       = "GET"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    LLOYD_GEORGE_BUCKET_NAME = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
  LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}" }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.ndr-lloyd-george-store,
    module.lloyd_george_reference_dynamodb_table,
    module.lloyd-george-stitch-gateway
  ]
}
