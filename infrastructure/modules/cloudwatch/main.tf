resource "aws_cognito_identity_pool" "rum_identity_pool" {
  identity_pool_name               = "${terraform.workspace}-rum-identity-pool"
  allow_unauthenticated_identities = true
}

resource "aws_cloudwatch_rum_app_monitor" "app_monitor" {
  name             = "${terraform.workspace}-app-monitor"
  domain           = "*.patient-deductions.nhs.uk"
  cw_log_enabled   = true
  identity_pool_id = aws_cognito_identity_pool.rum_identity_pool.id

  app_monitor_configuration {
    allow_cookies       = true
    enable_xray         = true
    session_sample_rate = 1.0
    telemetries         = ["errors", "performance", "http"]
  }
}

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