module "nems-message-lambda" {
  source         = "./modules/lambda"
  name           = "NemsMessageLamba"
  handler        = "handlers.nems_message_handler.lambda_handler"
  lambda_timeout = 60
  iam_role_policies = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy",
    module.lloyd_george_reference_dynamodb_table.dynamodb_policy,
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    WORKSPACE                = terraform.workspace
    LLOYD_GEORGE_BUCKET_NAME = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    NEMS_SQS_QUEUE_URL       = module.sqs-nems-queue[0].sqs_url
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false

  depends_on = [
    aws_iam_role.mesh_forwarder,
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.lloyd_george_reference_dynamodb_table,
    module.sqs-nems-queue,
  ]
}