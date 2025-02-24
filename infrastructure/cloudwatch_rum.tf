resource "aws_iam_role" "cognito_unauth_role" {
  name = "${terraform.workspace}-cognito-unauth-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.rum_identity_pool[0].id
          },
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "cognito_rum_policy" {
  name        = "${terraform.workspace}-github-actions-cognito-rum-policy"
  description = "Allows GitHub Actions to create Cognito Identity Pools and RUM App Monitors"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cognito-identity:CreateIdentityPool",
          "cognito-identity:DescribeIdentityPool",
          "cognito-identity:DeleteIdentityPool",
          "cognito-identity:UpdateIdentityPool"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "rum:CreateAppMonitor",
          "rum:DescribeAppMonitor",
          "rum:DeleteAppMonitor",
          "rum:UpdateAppMonitor"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cognito_unauth_policy" {
  name = "${terraform.workspace}-cognito-unauth-policy"
  role = aws_iam_role.cognito_unauth_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_rum_policy_attachment" {
  role       = aws_iam_role.cognito_rum_policy.id 
  policy_arn = aws_iam_policy.github_actions_cognito_rum_policy.arn
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
}
