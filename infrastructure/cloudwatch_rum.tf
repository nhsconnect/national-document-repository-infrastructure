locals {
  cognito_role_name = "${terraform.workspace}-cognito-unauth-role"
  cw_log_group      = "/aws/rum/my-rum-monitor/${terraform.workspace}-app-monitor"
}

resource "aws_iam_role" "cognito_unauthenticated" {
  count = local.is_production ? 0 : 1
  name  = local.cognito_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal : {
          Federated : "cognito-identity.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.cloudwatch_rum[0].id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_rum_cognito_access" {
  count       = local.is_production ? 0 : 1
  name        = "${terraform.workspace}-cloudwatch-rum-cognito-access-policy"
  description = "Policy for unauthenticated Cognito identities"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "rum:PutRumEvents",
          "Resource" : "arn:aws:rum:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:appmonitor/${aws_rum_app_monitor.ndr[0].id}"
        }
      ]
  })
}

resource "aws_cloudwatch_log_resource_policy" "rum_log" {
  policy_name = "AWSRUMLoggingPolicy"

  policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "rum.amazonaws.com"
        },
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DeleteResourcePolicy",
          "logs:DeleteLogGroup",
          "logs:DescribeLogGroups"
        ],
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vendedlogs/RUMService-*"
      }
    ]
  })
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_iam_role_policy_attachment" "cloudwatch_rum_cognito_unauth" {
  count      = local.is_production ? 0 : 1
  role       = aws_iam_role.cognito_unauthenticated[0].name
  policy_arn = aws_iam_policy.cloudwatch_rum_cognito_access[0].arn
}

resource "aws_cognito_identity_pool_roles_attachment" "cloudwatch_rum" {
  count            = local.is_production ? 0 : 1
  identity_pool_id = aws_cognito_identity_pool.cloudwatch_rum[0].id

  roles = {
    unauthenticated = aws_iam_role.cognito_unauthenticated[0].arn
  }
}

resource "aws_cognito_identity_pool" "cloudwatch_rum" {
  count                            = local.is_production ? 0 : 1
  identity_pool_name               = "${terraform.workspace}-cloudwatch-rum-identity-pool"
  allow_unauthenticated_identities = true
}

resource "aws_rum_app_monitor" "ndr" {
  count          = local.is_production ? 0 : 1
  name           = "${terraform.workspace}-app-monitor"
  domain         = "*.${var.domain}"
  cw_log_enabled = true

  app_monitor_configuration {
    identity_pool_id    = aws_cognito_identity_pool.cloudwatch_rum[0].id
    allow_cookies       = true
    enable_xray         = false
    session_sample_rate = 1.0
    telemetries         = ["errors", "performance", "http"]
  }

  depends_on = [aws_cloudwatch_log_resource_policy.rum_log]
}
