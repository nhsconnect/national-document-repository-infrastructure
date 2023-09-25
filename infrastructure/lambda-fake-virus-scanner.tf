module "fake-virus-scanner-lambda" {
  source  = "./modules/lambda"
  name    = "FakeVirusScannerLambda"
  handler = "handlers.fake_virus_scan_handler.lambda_handler"
  iam_role_policies = [
    module.document_reference_dynamodb_table.dynamodb_policy,
    module.ndr-document-store.s3_object_access_policy,
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  ]
  rest_api_id       = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id       = module.create-doc-ref-gateway.gateway_resource_id
  http_method       = "POST"
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    DOCUMENT_STORE_BUCKET_NAME   = "${terraform.workspace}-${var.docstore_bucket_name}"
    DOCUMENT_STORE_DYNAMODB_NAME = "${terraform.workspace}_DocumentReferenceMetadata"
  }
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.document_reference_dynamodb_table,
    module.create-doc-ref-gateway
  ]
}
