locals {
  is_mesh_enabled   = !contains(["ndra", "ndrb", "ndrc", "ndrd", "ndr-test"], terraform.workspace)
  cognito_role_name = "${var.environment}-cognito-unauth-role"
  rum_role_name     = "${var.environment}-rum-service-role"
}

data "aws_iam_policy_document" "cognito_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "rum_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["rum.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cognito_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "rum_management_policy" {
  statement {
    effect = "Allow"
    actions = [
      "rum:CreateAppMonitor",
      "rum:DescribeAppMonitor",
      "rum:DeleteAppMonitor",
      "rum:UpdateAppMonitor",
      "rum:TagResource",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "iam:PassRole"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "cognito_unauth_role" {
  name               = local.cognito_role_name
  assume_role_policy = data.aws_iam_policy_document.cognito_assume_role_policy.json
}

resource "aws_iam_role" "rum_service_role" {
  name               = local.rum_role_name
  assume_role_policy = data.aws_iam_policy_document.rum_assume_role_policy.json
}

resource "aws_iam_policy" "cognito_access_policy" {
  name        = "${var.environment}-cognito-access-policy"
  description = "Policy for unauthenticated Cognito identities"
  policy      = data.aws_iam_policy_document.cognito_access_policy.json
}

resource "aws_iam_role_policy_attachment" "cognito_unauth_policy_attachment" {
  role       = aws_iam_role.cognito_unauth_role.name
  policy_arn = aws_iam_policy.cognito_access_policy.arn
}

resource "aws_iam_policy" "rum_management_policy" {
  name        = "${var.environment}-rum-management-policy"
  description = "Policy to manage RUM app monitors and associated logs"
  policy      = data.aws_iam_policy_document.rum_management_policy.json
}

resource "aws_iam_role_policy_attachment" "rum_policy_attachment" {
  role       = aws_iam_role.rum_service_role.name
  policy_arn = aws_iam_policy.rum_management_policy.arn
}


resource "aws_cognito_identity_pool" "rum_identity_pool" {
  count                            = local.is_mesh_enabled ? 0 : 1
  identity_pool_name               = "${var.environment}-rum-identity-pool"
  allow_unauthenticated_identities = true
}

resource "aws_cognito_identity_pool_roles_attachment" "rum_identity_pool_roles" {
  count            = local.is_mesh_enabled ? 0 : 1
  identity_pool_id = aws_cognito_identity_pool.rum_identity_pool[0].id

  roles = {
    unauthenticated = aws_iam_role.cognito_unauth_role.arn
  }
}

resource "aws_rum_app_monitor" "app_monitor" {
  count          = local.is_production ? 0 : 1
  name           = "${var.environment}-app-monitor"
  domain         = "*.patient-deductions.nhs.uk"
  cw_log_enabled = true

  app_monitor_configuration {
    allow_cookies       = true
    enable_xray         = true
    session_sample_rate = 1.0
    telemetries         = ["errors", "performance", "http"]
  }

  tags = {
    ServiceRole = aws_iam_role.rum_service_role.arn
  }
}