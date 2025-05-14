data "aws_ssm_parameter" "teams_alerting_webhook_url" {
  name = "/ndr/poc/alerting/teams/webhook_url"
}

data "aws_ssm_parameter" "teams_alerting_confluence_page" {
  name = "/ndr/poc/alerting/confluence"
}

data "aws_ssm_parameter" "slack_alerting_channel_id" {
  name = "/ndr/poc/alerting/slack/channel_id"
}

data "aws_ssm_parameter" "slack_bot_token" {
  name = "/ndr/poc/alerting/slack/bot_token"
}

module "teams-alerting-lambda" {
  source  = "./modules/lambda"
  name    = "TeamsAlertingLambda"
  handler = "handlers.teams_alerting_handler.lambda_handler"
  iam_role_policy_documents = [
    aws_iam_policy.ssm_access_policy.policy,
    aws_iam_policy.alerting_alarms_policy.policy,
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
    WEBHOOK_URL                 = data.aws_ssm_parameter.teams_alerting_webhook_url.value
    CONFLUENCE_BASE_URL         = data.aws_ssm_parameter.teams_alerting_confluence_page.value
    ALARM_HISTORY_DYNAMODB_NAME = "${terraform.workspace}_${var.alarm_state_history_table_name}"
    ALERTING_SLACK_CHANNEL_ID   = data.aws_ssm_parameter.slack_alerting_channel_id.value
    ALERTING_SLACK_BOT_TOKEN    = data.aws_ssm_parameter.slack_bot_token.value
  }
  is_gateway_integration_needed = false
  is_invoked_from_gateway       = false
  lambda_timeout                = 900
}


resource "aws_sns_topic_subscription" "teams_alerting" {
  endpoint  = module.teams-alerting-lambda.lambda_arn
  protocol  = "lambda"
  topic_arn = aws_sns_topic.alarm_notifications_topic[0].arn
}

resource "aws_lambda_permission" "invoke_with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.teams-alerting-lambda.lambda_arn
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alarm_notifications_topic[0].arn
}

resource "aws_iam_policy" "alerting_alarms_policy" {
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