resource "aws_cloudwatch_log_group" "ndr_cloudwatch_log_group" {
  name              = var.cloudwatch_log_group_name
  retention_in_days = var.retention_in_days

  tags = {
    Name        = "${terraform.workspace}_${var.cloudwatch_log_group_name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}
