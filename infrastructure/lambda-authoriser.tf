module "authoriser-lambda" {
  source  = "./modules/lambda"
  name    = "AuthoriserLambda"
  handler = "handlers.authoriser_handler.lambda_handler"
  iam_role_policy_documents = [
    aws_iam_policy.ssm_access_policy_authoriser.policy,
    module.auth_session_dynamodb_table.dynamodb_read_policy_document,
    module.auth_session_dynamodb_table.dynamodb_write_policy_document,
    module.ndr-app-config.app_config_policy
  ]
  kms_deletion_window = var.kms_deletion_window
  rest_api_id         = aws_api_gateway_rest_api.ndr_doc_store_api.id
  api_execution_arn   = aws_api_gateway_rest_api.ndr_doc_store_api.execution_arn
  lambda_environment_variables = {
    APPCONFIG_APPLICATION          = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT          = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION        = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                      = terraform.workspace
    SSM_PARAM_JWT_TOKEN_PUBLIC_KEY = "jwt_token_public_key"
    AUTH_SESSION_TABLE_NAME        = "${terraform.workspace}_${var.auth_session_dynamodb_table_name}"
  }
  http_methods                  = ["GET"]
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = true

  depends_on = [
    aws_iam_policy.ssm_access_policy_authoriser,
    module.auth_session_dynamodb_table,
    aws_api_gateway_rest_api.ndr_doc_store_api,
    module.ndr-app-config
  ]
}

module "authoriser-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.authoriser-lambda.function_name
  lambda_timeout       = module.authoriser-lambda.timeout
  lambda_name          = "authoriser_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.authoriser-alarm-topic.arn]
  ok_actions           = [module.authoriser-alarm-topic.arn]
  depends_on           = [module.authoriser-lambda, module.authoriser-alarm-topic]
}


module "authoriser-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "create_doc-alarms-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.authoriser-lambda.lambda_arn
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

  depends_on = [module.authoriser-lambda, module.sns_encryption_key]
}

resource "aws_api_gateway_authorizer" "repo_authoriser" {
  name                             = "${terraform.workspace}_repo_authoriser"
  type                             = "REQUEST"
  identity_source                  = "method.request.header.Authorization"
  rest_api_id                      = aws_api_gateway_rest_api.ndr_doc_store_api.id
  authorizer_uri                   = module.authoriser-lambda.invoke_arn
  authorizer_result_ttl_in_seconds = 0
}

resource "aws_iam_policy" "ssm_access_policy_authoriser" {
  name = "${terraform.workspace}_ssm_public_token_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParametersByPath"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/jwt_token_public_key",
        ]
      }
    ]
  })
}

