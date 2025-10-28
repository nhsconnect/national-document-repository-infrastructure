resource "aws_iam_policy" "ssm_access_policy" {
  name = "${terraform.workspace}_ssm_parameters"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:PutParameter"
        ],
        Resource = [
          "arn:aws:ssm:*:*:parameter/*",
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "read_only_role_extra_permissions" {
  count = local.is_sandbox ? 0 : 1
  name  = "ReadOnlyExtraAccess"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
        ],
        Resource = [
          "arn:aws:kms:eu-west-2:${data.aws_caller_identity.current.account_id}:key/*",
        ]
      }
    ]
  })
  tags = {
    Name      = "ReadOnlyExtraAccess"
    Workspace = "core"
  }
}

resource "aws_iam_policy" "administrator_permission_restrictions" {
  count = local.is_sandbox ? 0 : 1
  name  = "AdministratorRestriction"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:PutLifecycleConfiguration",
          "s3:PutObject",
          "s3:RestoreObject"
        ],
        Resource = [
          "arn:aws:s3:::*/*.tfstate"
        ]
      }
    ]
  })
  tags = {
    Name      = "AdministratorRestriction"
    Workspace = "core"
  }
}
