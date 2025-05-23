data "aws_ssm_parameter" "teams_alerting_webhook_url" {
  name = "/ndr/alerting/teams/webhook_url"
}

data "aws_ssm_parameter" "im_alerting_confluence_url" {
  name = "/ndr/alerting/confluence/url"
}

data "aws_ssm_parameter" "slack_alerting_channel_id" {
  name = "/ndr/alerting/slack/channel_id"
}

data "aws_ssm_parameter" "slack_alerting_bot_token" {
  name = "/ndr/alerting/slack/bot_token"
}

module "im-alerting-lambda" {
  source  = "./modules/lambda"
  name    = "IMAlertingLambda"
  handler = "handlers.im_alerting_handler.lambda_handler"
  iam_role_policy_documents = [
    aws_iam_policy.ssm_access_policy.policy,
    aws_iam_policy.alerting_lambda_alarms.policy,
    module.ndr-app-config.app_config_policy,
    module.alarm_state_history_table.dynamodb_read_policy_document,
    module.alarm_state_history_table.dynamodb_write_policy_document
  ]
  rest_api_id       = null
  api_execution_arn = null
  lambda_environment_variables = {
    APPCONFIG_APPLICATION       = module.ndr-app-config.app_config_application_id
    APPCONFIG_ENVIRONMENT       = module.ndr-app-config.app_config_environment_id
    APPCONFIG_CONFIGURATION     = module.ndr-app-config.app_config_configuration_profile_id
    WORKSPACE                   = terraform.workspace
    TEAMS_WEBHOOK_URL           = data.aws_ssm_parameter.teams_alerting_webhook_url.value
    CONFLUENCE_BASE_URL         = data.aws_ssm_parameter.im_alerting_confluence_url.value
    ALARM_HISTORY_DYNAMODB_NAME = "${terraform.workspace}_${var.alarm_state_history_table_name}"
    SLACK_CHANNEL_ID            = data.aws_ssm_parameter.slack_alerting_channel_id.value
    SLACK_BOT_TOKEN             = data.aws_ssm_parameter.slack_alerting_bot_token.value
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
  lambda_timeout                = 900
}

resource "aws_sns_topic_subscription" "im_alerting" {
  endpoint  = module.im-alerting-lambda.lambda_arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.alarm_notifications_topic[0].arn
}

resource "aws_lambda_permission" "im_alerting_lambda_invoke_with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.im-alerting-lambda.lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_notifications_topic[0].arn
}

resource "aws_iam_policy" "alerting_lambda_alarms" {
  name        = "${terraform.workspace}_alerting_lambda_alarms_policy"
  description = "Alarms policy to allow lambda to describe all alarms"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:DescribeAlarms"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:cloudwatch:${var.region}:${data.aws_caller_identity.current.account_id}:alarm:*"
      },
    ]
  })
}