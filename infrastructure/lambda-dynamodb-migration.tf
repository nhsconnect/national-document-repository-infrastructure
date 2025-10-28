module "migration-dynamodb-lambda" {
  source  = "./modules/lambda"
  name    = "MigrationDynamoDB"
  handler = "handlers.migration_dynamodb_handler.lambda_handler"

  iam_role_policy_documents = [
    module.lloyd_george_reference_dynamodb_table.dynamodb_read_policy_document,
    module.lloyd_george_reference_dynamodb_table.dynamodb_write_policy_document,
    module.bulk_upload_report_dynamodb_table.dynamodb_read_policy_document,
    module.ndr-bulk-staging-store.s3_read_policy_document,
    module.ndr-lloyd-george-store.s3_read_policy_document,
    aws_iam_policy.ssm_access_policy.policy,
    module.ndr-app-config.app_config_policy
  ]

  kms_deletion_window           = var.kms_deletion_window
  rest_api_id                   = null
  api_execution_arn             = null
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false

  lambda_environment_variables = {
    WORKSPACE               = terraform.workspace
    APPCONFIG_APPLICATION   = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT   = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION = module.ndr-app-config.app_config_configuration_profile_id
  }

  lambda_timeout                 = 900
  memory_size                    = 1024
  reserved_concurrent_executions = contains(["prod"], terraform.workspace) ? 100 : 5

  depends_on = [
    module.lloyd_george_reference_dynamodb_table,
    module.bulk_upload_report_dynamodb_table,
    module.ndr-app-config,
    aws_iam_policy.ssm_access_policy,
  ]
}
