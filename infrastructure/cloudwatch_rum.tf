resource "aws_cognito_identity_pool" "rum_identity_pool" {
  identity_pool_name               = "${terraform.workspace}-rum-identity-pool"
  allow_unauthenticated_identities = true
  count = local.is_production ? 0 : 1
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
  
  count = local.is_production ? 0 : 1
}