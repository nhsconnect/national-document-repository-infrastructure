module "document_review_processor_lambda" {
  source  = "./modules/lambda"
  name    = "DocumentReviewProcessor"
  handler = "handlers.document_review_processor.lambda_handler"
  iam_role_policy_documents = [
    module.document_review_queue.sqs_read_policy_document,
    module.document_review_queue.sqs_write_policy_document,
  ]
  kms_deletion_window           = var.kms_deletion_window
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
  rest_api_id                   = null
  api_execution_arn             = null
  lambda_timeout                = 900
  lambda_environment_variables = {
    DOCUMENT_REVIEW_BUCKET_NAME = "${terraform.workspace}-placeholder-document-review-bucket"
    DOCUMENT_REVIEW_TABLE_NAME  = "${terraform.workspace}_placeholder_document_review_table"
    WORKSPACE                   = terraform.workspace
  }
  depends_on = []
}


resource "aws_lambda_event_source_mapping" "document-review-processor" {
  event_source_arn = module.document_review_queue.endpoint
  function_name    = module.document_review_processor_lambda.lambda_arn
}
