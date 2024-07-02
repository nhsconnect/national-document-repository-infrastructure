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
  schedule_expression = "cron(0 20 * * ? *)"
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
  schedule_expression = "cron(0 8 ? * 2 *)"
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