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

resource "aws_scheduler_schedule" "ods_weekly_update_ecs" {
  count       = local.is_sandbox ? 0 : 1
  name_prefix = "${terraform.workspace}_ods_weekly_update_ecs"
  description = "A weekly trigger for the ods update run"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 4 ? * SAT *)"

  target {
    arn      = module.ndr-ecs-fargate-ods-update[0].ecs_cluster_arn
    role_arn = aws_iam_role.ods_weekly_update_ecs_execution[0].arn
    ecs_parameters {
      task_definition_arn = replace(module.ndr-ecs-fargate-ods-update[0].task_definition_arn, "/:[0-9]+$/", "")
      task_count          = 1
      launch_type         = "FARGATE"
      network_configuration {
        assign_public_ip = false
        security_groups  = [module.ndr-ecs-fargate-ods-update[0].security_group_id]
        subnets          = [for subnet in module.ndr-vpc-ui.private_subnets : subnet]
      }
    }
  }
}

resource "aws_iam_role" "ods_weekly_update_ecs_execution" {
  count = local.is_sandbox ? 0 : 1
  name  = "${terraform.workspace}_ods_weekly_update_scheduler_role"
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

resource "aws_iam_role_policy_attachment" "test-attach" {
  count      = local.is_sandbox ? 0 : 1
  role       = aws_iam_role.ods_weekly_update_ecs_execution[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}