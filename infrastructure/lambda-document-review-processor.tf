module "document_review_processor_lambda" {
  source  = "./modules/lambda"
  name    = "DocumentReviewProcessor"
  handler = "handlers.document_review_processor_handler.lambda_handler"
  iam_role_policy_documents = [
    module.document_review_queue.sqs_read_policy_document,
    module.document_review_queue.sqs_write_policy_document,
    module.document_review_dynamodb_table.dynamodb_read_policy_document,
    module.document_review_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-bulk-staging-store.s3_read_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.ndr-document-pending-review-store.s3_write_policy_document
  ]
  kms_deletion_window           = var.kms_deletion_window
  memory_size                   = 512
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
  rest_api_id                   = null
  api_execution_arn             = null
  lambda_timeout                = 900
  lambda_environment_variables = {
    PENDING_REVIEW_BUCKET_NAME    = module.ndr-document-pending-review-store.bucket_id
    STAGING_STORE_BUCKET_NAME     = module.ndr-bulk-staging-store.bucket_id
    DOCUMENT_REVIEW_DYNAMODB_NAME = module.document_review_dynamodb_table.table_name
    WORKSPACE                     = terraform.workspace
  }
  depends_on = []
}

resource "aws_lambda_event_source_mapping" "document-review-processor" {
  event_source_arn = module.document_review_queue.endpoint
  function_name    = module.document_review_processor_lambda.lambda_arn
}
