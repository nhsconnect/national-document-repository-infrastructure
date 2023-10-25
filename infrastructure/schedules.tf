resource "aws_cloudwatch_event_rule" "bulk_upload_metadata_schedule" {
  name                = "${terraform.workspace}_bulk_upload_metadata_schedule"
  description         = "Schedule for Bulk Upload Metadata Lambda"
  schedule_expression = "cron(0 19 * * ? *)"
}

resource "aws_cloudwatch_event_target" "bulk_upload_metadata_schedule_event" {
  rule      = aws_cloudwatch_event_rule.bulk_upload_metadata_schedule.name
  target_id = "bulk_upload_metadata_schedule"

  arn = module.bulk-upload-metadata-lambda.endpoint
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
  arn       = module.bulk-upload-report-lambda.endpoint
  depends_on = [
    module.bulk-upload-report-lambda,
    aws_cloudwatch_event_rule.bulk_upload_report_schedule

  ]
}
resource "aws_lambda_permission" "bulk_upload_report_schedule_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = ["lambda:InvokeFunction""events:PutRole"]
  function_name = module.bulk-upload-report-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.bulk_upload_report_schedule.arn
  depends_on = [
    module.bulk-upload-report-lambda,
    aws_cloudwatch_event_rule.bulk_upload_report_schedule
  ]
}