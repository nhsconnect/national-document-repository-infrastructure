resource "aws_cloudwatch_log_group" "ndr_cloudwatch_log_group" {
  name              = "${terraform.workspace}_${var.cloudwatch_log_group_name}_log_group"
  retention_in_days = var.retention_in_days

  tags = {
    Name        = "${terraform.workspace}_${var.cloudwatch_log_group_name}_log_stream"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${terraform.workspace}_${var.cloudwatch_log_stream_name}_log_Stream"
  log_group_name = "aws_cloudwatch_log_group.ndr_cloudwatch_log_group"
  tags = {
    Name        = "${terraform.workspace}_${var.cloudwatch_log_stream_name}_log_stream"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}