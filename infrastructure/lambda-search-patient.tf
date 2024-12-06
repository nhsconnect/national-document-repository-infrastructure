module "search-patient-details-gateway" {
  # Gateway Variables
  source              = "./modules/gateway"
  api_gateway_id      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  parent_id           = aws_api_gateway_rest_api.ndr_doc_store_api.root_resource_id
  http_methods        = ["GET"]
  authorization       = "CUSTOM"
  gateway_path        = "SearchPatient"
  authorizer_id       = aws_api_gateway_authorizer.repo_authoriser.id
  require_credentials = true
  origin              = contains(["prod"], terraform.workspace) ? "'https://${var.domain}'" : "'https://${terraform.workspace}.${var.domain}'"

  # Lambda Variables
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  owner             = var.owner
  environment       = var.environment

  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
  ]
}

module "search_patient_alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.search-patient-details-lambda.function_name
  lambda_timeout       = module.search-patient-details-lambda.timeout
  lambda_name          = "search_patient_details_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.search_patient_alarm_topic.arn]
  ok_actions           = [module.search_patient_alarm_topic.arn]
  depends_on           = [module.search-patient-details-lambda, module.search_patient_alarm_topic]
}


module "search_patient_alarm_topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  current_account_id    = data.aws_caller_identity.current.account_id
  topic_name            = "search_patient_details_alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.search-patient-details-lambda.lambda_arn
  depends_on            = [module.sns_encryption_key]
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

module "search-patient-details-lambda" {
  source  = "./modules/lambda"
  name    = "SearchPatientDetailsLambda"
  handler = "handlers.search_patient_details_handler.lambda_handler"
  iam_role_policy_documents = [
    aws_iam_policy.ssm_access_policy.policy,
    module.ndr-app-config.app_config_policy
  ]
  rest_api_id  = aws_api_gateway_rest_api.ndr_doc_store_api.id
  resource_id  = module.search-patient-details-gateway.gateway_resource_id
  http_methods = ["GET"]
  memory_size  = 1769
  lambda_environment_variables = {
    APPCONFIG_APPLICATION          = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT          = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION        = module.ndr-app-config.app_config_configuration_profile_id
    SSM_PARAM_JWT_TOKEN_PUBLIC_KEY = "jwt_token_public_key"
    PDS_FHIR_IS_STUBBED            = local.is_sandbox,
    SPLUNK_SQS_QUEUE_URL           = try(module.sqs-splunk-queue[0].sqs_url, null)
    WORKSPACE                      = terraform.workspace
  }
  api_execution_arn = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  depends_on = [
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.search-patient-details-gateway,
    aws_iam_policy.lambda_audit_splunk_sqs_queue_send_policy[0],
    module.ndr-app-config
  ]
}

resource "aws_iam_role_policy_attachment" "policy_audit_search-patient-details-lambda" {
  count      = local.is_sandbox ? 0 : 1
  role       = module.search-patient-details-lambda.lambda_execution_role_name
  policy_arn = try(aws_iam_policy.lambda_audit_splunk_sqs_queue_send_policy[0].arn, null)
}
