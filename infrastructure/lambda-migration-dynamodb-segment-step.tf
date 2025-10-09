module "migration-dynamodb-segment-step-lambda" {
  source         = "./modules/lambda"
  name           = "MigrationDynamodbSegmentStepLambda"
  handler        = "handlers.migration_dynamodb_segment_step.lambda_handler"
  lambda_timeout = 900
  memory_size    = 1769
  iam_role_policy_documents = [
    module.migration-dynamodb-segment-store.s3_read_policy_document,
    module.migration-dynamodb-segment-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]
  kms_deletion_window = var.kms_deletion_window

  lambda_environment_variables = {
    APPCONFIG_APPLICATION         = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT         = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION       = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                     = terraform.workspace
    MIGRATION_SEGMENT_BUCKET_NAME = "${terraform.workspace}-${var.migration_dynamodb_segment_store_bucket_name}"
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
}
