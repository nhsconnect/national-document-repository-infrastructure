module "bulk_upload_metadata_preprocessor_lambda" {
  source  = "./modules/lambda"
  name    = "BulkUploadMetadataPreprocessor"
  handler = "handlers.bulk_upload_metadata_preprocessor_handler.lambda_handler"

  iam_role_policy_documents = [
    module.ndr-bulk-staging-store.s3_read_policy_document,
    module.ndr-bulk-staging-store.s3_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = null
  api_execution_arn   = null

  lambda_environment_variables = {
    APPCONFIG_APPLICATION     = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT     = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION   = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                 = terraform.workspace
    STAGING_STORE_BUCKET_NAME = "${terraform.workspace}-${var.staging_store_bucket_name}"
  }

  is_gateway_integration_needed  = false
  is_invoked_from_gateway        = false
  lambda_timeout                 = 900
  memory_size                    = 1769
  reserved_concurrent_executions = local.bulk_upload_lambda_concurrent_limit
}

