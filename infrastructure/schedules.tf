resource "aws_cloudwatch_event_rule" "bulk_upload_metadata_schedule" {
  name                = "${terraform.workspace}_bulk_upload_metadata_schedule"
  description         = "Schedule for Bulk Upload Metadata Lambda"
  schedule_expression = "cron(0 19 * * ? *)"
}

resource "aws_cloudwatch_event_target" "bulk_upload_metadata_schedule_event" {
  rule      = aws_cloudwatch_event_rule.bulk_upload_metadata_schedule.name
  target_id = "bulk_upload_metadata_schedule"

  arn = module.bulk-upload-metadata-lambda.lambda_arn
  depends_on = [
    module.bulk-upload-metadata-lambda,
    aws_cloudwatch_event_rule.bulk_upload_metadata_schedule
  ]
}

resource "aws_lambda_permission" "bulk_upload_metadata_schedule_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.bulk-upload-metadata-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bulk_upload_metadata_schedule.arn
  depends_on = [
    module.bulk-upload-metadata-lambda,
    aws_cloudwatch_event_rule.bulk_upload_metadata_schedule
  ]
}

resource "aws_cloudwatch_event_rule" "bulk_upload_report_schedule" {
  name                = "${terraform.workspace}_bulk_upload_report_schedule"
  description         = "Schedule for Bulk Upload Report Lambda"
  schedule_expression = "cron(0 7 * * ? *)"
}

resource "aws_cloudwatch_event_target" "bulk_upload_report_schedule_event" {
  rule      = aws_cloudwatch_event_rule.bulk_upload_report_schedule.name
  target_id = "bulk_upload_report_schedule"
  arn       = module.bulk-upload-report-lambda.lambda_arn

  depends_on = [
    module.bulk-upload-report-lambda,
    aws_cloudwatch_event_rule.bulk_upload_report_schedule
  ]
}

resource "aws_lambda_permission" "bulk_upload_report_schedule_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.bulk-upload-report-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bulk_upload_report_schedule.arn

  depends_on = [
    module.bulk-upload-report-lambda,
    aws_cloudwatch_event_rule.bulk_upload_report_schedule
  ]
}

resource "aws_cloudwatch_event_rule" "data_collection_schedule" {
  name                = "${terraform.workspace}_data_collection_schedule"
  description         = "Schedule for Data Collection Lambda"
  schedule_expression = "cron(0 20 ? * SAT *)"
}

resource "aws_cloudwatch_event_target" "data_collection_schedule_event" {
  rule      = aws_cloudwatch_event_rule.data_collection_schedule.name
  target_id = "data_collection_schedule"

  arn = module.data-collection-lambda.lambda_arn
  depends_on = [
    module.data-collection-lambda,
    aws_cloudwatch_event_rule.data_collection_schedule
  ]
}

resource "aws_lambda_permission" "data_collection_schedule_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.data-collection-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.data_collection_schedule.arn
  depends_on = [
    module.data-collection-lambda,
    aws_cloudwatch_event_rule.data_collection_schedule
  ]
}

resource "aws_cloudwatch_event_rule" "statistical_report_schedule" {
  name                = "${terraform.workspace}_statistical_report_schedule"
  description         = "Schedule for Statistical Report Lambda"
  schedule_expression = "cron(0 8 ? * MON *)"
}

resource "aws_cloudwatch_event_target" "statistical_report_schedule_event" {
  rule      = aws_cloudwatch_event_rule.statistical_report_schedule.name
  target_id = "statistical_report_schedule"

  arn = module.statistical-report-lambda.lambda_arn
  depends_on = [
    module.statistical-report-lambda,
    aws_cloudwatch_event_rule.statistical_report_schedule
  ]
}

resource "aws_lambda_permission" "statistical_report_schedule_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.statistical-report-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.statistical_report_schedule.arn
  depends_on = [
    module.statistical-report-lambda,
    aws_cloudwatch_event_rule.statistical_report_schedule
  ]
}

resource "aws_scheduler_schedule" "data_collection_ecs" {
  count       = local.is_sandbox ? 0 : 1
  name_prefix = "${terraform.workspace}_data_collection_ecs"
  description = "A weekly trigger for the data collection run"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 4 ? * SAT *)"

  target {
    arn      = module.ndr-ecs-fargate-data-collection[0].ecs_cluster_arn
    role_arn = aws_iam_role.data_collection_ecs_execution[0].arn
    ecs_parameters {
      task_definition_arn = replace(module.ndr-ecs-fargate-data-collection[0].task_definition_arn, "/:[0-9]+$/", "")
      task_count          = 1
      launch_type         = "FARGATE"
      network_configuration {
        assign_public_ip = false
        security_groups  = [module.ndr-ecs-fargate-data-collection[0].security_group_id]
        subnets          = [for subnet in module.ndr-vpc-ui.private_subnets : subnet]
      }
    }
  }
}

resource "aws_iam_role" "data_collection_ecs_execution" {
  count = local.is_sandbox ? 0 : 1
  name  = "${terraform.workspace}_data_collection_scheduler_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "data_collection_ecs_execution" {
  count      = local.is_sandbox ? 0 : 1
  role       = aws_iam_role.data_collection_ecs_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}

resource "aws_cloudwatch_event_rule" "nhs_oauth_token_generator_schedule" {
  name                = "${terraform.workspace}_nhs_oauth_token_generator_schedule"
  description         = "Schedule for NHS OAuth Token Generator Lambda"
  schedule_expression = "rate(9 minutes)"
}

resource "aws_cloudwatch_event_target" "nhs_oauth_token_generator_schedule" {
  rule      = aws_cloudwatch_event_rule.nhs_oauth_token_generator_schedule.name
  target_id = "nhs_oauth_token_generator_schedule"
  arn       = module.nhs-oauth-token-generator-lambda.lambda_arn
}

resource "aws_lambda_permission" "nhs_oauth_token_generator_schedule" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = module.nhs-oauth-token-generator-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.nhs_oauth_token_generator_schedule.arn
}
resource "aws_cloudwatch_event_rule" "bulk_upload_enable_rule" {
  name                = "${terraform.workspace}_bulk_upload_enable"
  description         = "Enable Bulk Upload ingestion"
  schedule_expression = "cron(0/2 * * * ? *)" # TODO set to "cron(0 19 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_rule" "bulk_upload_disable_rule" {
  name                = "${terraform.workspace}_bulk_upload_disable"
  description         = "Disable Bulk Upload ingestion"
  schedule_expression = "cron(1/2 * * * ? *)" # TODO set to "cron(0 7 ? * TUE-SAT *)"
}

resource "aws_cloudwatch_event_target" "bulk_upload_enable_target" {
  rule      = aws_cloudwatch_event_rule.bulk_upload_enable_rule.name
  target_id = "toggle-bulk-upload-enable"
  arn       = module.toggle-bulk-upload-lambda.lambda_arn
  input     = jsonencode({ action = "enable" })
}

resource "aws_cloudwatch_event_target" "bulk_upload_disable_target" {
  rule      = aws_cloudwatch_event_rule.bulk_upload_disable_rule.name
  target_id = "toggle-bulk-upload-disable"
  arn       = module.toggle-bulk-upload-lambda.lambda_arn
  input     = jsonencode({ action = "disable" })
}

resource "aws_lambda_permission" "toggle_bulk_upload_enable_permission" {
  statement_id  = "AllowExecutionFromCloudWatchEnable"
  action        = "lambda:InvokeFunction"
  function_name = module.toggle-bulk-upload-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bulk_upload_enable_rule.arn
}

resource "aws_lambda_permission" "toggle_bulk_upload_disable_permission" {
  statement_id  = "AllowExecutionFromCloudWatchDisable"
  action        = "lambda:InvokeFunction"
  function_name = module.toggle-bulk-upload-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bulk_upload_disable_rule.arn
}
