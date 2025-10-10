module "migration-dynamodb-segment-lambda" {
  source         = "./modules/lambda"
  name           = "MigrationDynamodbSegmentLambda"
  handler        = "handlers.migration_dynamodb_segment_handler.lambda_handler"
  lambda_timeout = 900
  memory_size    = 1769
  iam_role_policy_documents = [
    module.migration-dynamodb-segment-store.s3_read_policy_document,
    module.migration-dynamodb-segment-store.s3_write_policy_document
  ]
  kms_deletion_window = var.kms_deletion_window

  lambda_environment_variables = {
    WORKSPACE                     = terraform.workspace
    MIGRATION_SEGMENT_BUCKET_NAME = "${terraform.workspace}-${var.migration_dynamodb_segment_store_bucket_name}"
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
}
