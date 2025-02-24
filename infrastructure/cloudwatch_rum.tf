locals {
  cognito_role_name = "${terraform.workspace}-cognito-unauth-role"
  rum_role_name     = "${terraform.workspace}-rum-service-role"
}

resource "aws_iam_role" "cognito_unauth_role" {
  name = local.cognito_role_name

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",

        "Principal" : "*"

        "Action" : [
          "cognito-identity:*",
        ],
        "Condition" : {
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:cognito-idp:eu-west-2:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "rum_service_role" {
  name = local.rum_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "rum.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cognito_access_policy" {
  name        = "${terraform.workspace}-cognito-access-policy"
  description = "Policy for unauthenticated Cognito identities"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*",
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "rum_management_policy" {
  name        = "${terraform.workspace}-rum-management-policy"
  description = "Policy to manage RUM app monitors and associated logs"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rum:CreateAppMonitor",
          "rum:DescribeAppMonitor",
          "rum:DeleteAppMonitor",
          "rum:UpdateAppMonitor",
          "rum:TagResource",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_unauth_policy_attachment" {
  role       = aws_iam_role.cognito_unauth_role.name
  policy_arn = aws_iam_policy.cognito_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "rum_policy_attachment" {
  role       = aws_iam_role.rum_service_role.name
  policy_arn = aws_iam_policy.rum_management_policy.arn
}

resource "aws_cognito_identity_pool" "rum_identity_pool" {
  count                            = local.is_production ? 0 : 1
  identity_pool_name               = "${terraform.workspace}-rum-identity-pool"
  allow_unauthenticated_identities = true
}

resource "aws_cognito_identity_pool_roles_attachment" "rum_identity_pool_roles" {
  count            = local.is_production ? 0 : 1
  identity_pool_id = aws_cognito_identity_pool.rum_identity_pool[0].id

  roles = {
    unauthenticated = aws_iam_role.cognito_unauth_role.arn
  }
}

resource "aws_rum_app_monitor" "app_monitor" {
  count          = local.is_production ? 0 : 1
  name           = "${terraform.workspace}-app-monitor"
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