module "document_upload_check_lambda" {
  source  = "./modules/lambda"
  name    = "DocumentReferenceVirusScanCheck"
  handler = "handlers.document_reference_virus_scan_handler.lambda_handler"
  iam_role_policy_documents = [
    module.ndr-bulk-staging-store.s3_read_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.ndr-lloyd-george-store.s3_write_policy_document,
    aws_iam_policy.ssm_access_policy.policy,
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
  ]
  rest_api_id       = null
  http_methods      = null
  api_execution_arn = null
  lambda_environment_variables = {
    LLOYD_GEORGE_DYNAMODB_NAME = "${terraform.workspace}_${var.lloyd_george_dynamodb_table_name}"
    STAGING_STORE_BUCKET_NAME  = "${terraform.workspace}-${var.staging_store_bucket_name}"
    LLOYD_GEORGE_BUCKET_NAME   = "${terraform.workspace}-${var.lloyd_george_bucket_name}"
    WORKSPACE                  = terraform.workspace
  }
  lambda_timeout                = 900
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.ndr-bulk-staging-store,
    module.ndr-lloyd-george-store,
    module.lloyd_george_reference_dynamodb_table,
  ]
}


resource "aws_s3_bucket_notification" "document_upload_check_lambda-lambda-trigger" {
  bucket = module.ndr-bulk-staging-store.bucket_id
  lambda_function {
    lambda_function_arn = module.document_upload_check_lambda.lambda_arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "user_upload"
  }
}

resource "aws_lambda_permission" "document_upload_check_lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = module.document_upload_check_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${module.ndr-bulk-staging-store.bucket_id}"
}