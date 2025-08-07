module "nhs-oauth-token-generator-lambda" {
  source         = "./modules/lambda"
  name           = "NhsOauthTokenGeneratorLambda"
  handler        = "handlers.nhs_oauth_token_generator_handler.lambda_handler"
  lambda_timeout = 120
  iam_role_policy_documents = [
    aws_iam_policy.ssm_access_policy.policy,
    module.ndr-app-config.app_config_policy
  ]

  kms_deletion_window = var.kms_deletion_window
  account_id          = data.aws_caller_identity.current.account_id
  rest_api_id         = null
  api_execution_arn   = null

  lambda_environment_variables = {
    WORKSPACE = terraform.workspace
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
}

module "nhs-oauth-token-generator-alarm" {
  source               = "./modules/lambda_alarms"
  lambda_function_name = module.nhs-oauth-token-generator-lambda.function_name
  lambda_timeout       = module.nhs-oauth-token-generator-lambda.timeout
  lambda_name          = "nhs_oauth_token_generator_handler"
  namespace            = "AWS/Lambda"
  alarm_actions        = [module.nhs-oauth-token-generator-alarm-topic.arn]
  ok_actions           = [module.nhs-oauth-token-generator-alarm-topic.arn]
}

module "nhs-oauth-token-generator-alarm-topic" {
  source                = "./modules/sns"
  sns_encryption_key_id = module.sns_encryption_key.id
  topic_name            = "nhs-oauth-token-generator-topic"
  topic_protocol        = "lambda"
  topic_endpoint        = module.nhs-oauth-token-generator-lambda.lambda_arn
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
