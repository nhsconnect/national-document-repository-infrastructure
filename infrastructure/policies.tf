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

resource "aws_iam_policy" "production_support" {
  count = local.is_production ? 1 : 0
  name  = "ProductionSupport"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowListBucketsForConsole",
        Effect = "Allow",
        Action = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::*"
        ]
      },
      {
        Sid    = "AllowListRootFoldersInProdStagingBulkStore",
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::prod-staging-bulk-store"
        ]
        Condition = {
          StringEquals = {
            "s3:delimiter" = "/"
          }
          StringEqualsIfExists = {
            "s3:prefix" = ""
          }
        }
      },
      {
        Sid      = "AllowCreateRootFoldersOnlyInProdStagingBulkStore",
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::prod-staging-bulk-store/*"
        Condition = {
          StringLike = {
            "s3:prefix" = "[^/]+/"
          }
        }
      },
      {
        Sid    = "ExplicitDenyObjectAccessInProdStagingBulkStore",
        Effect = "Deny",
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectTagging"
        ],
        Resource = [
          "arn:aws:s3:::prod-staging-bulk-store/*"
        ]
      },
      {
        Sid    = "AWSTransferFamilyManager",
        Effect = "Allow",
        Action = [
          "transfer:CreateUser",
          "transfer:Describe*",
          "transfer:List*",
          "transfer:TestIdentityProvider",
        ],
        Resource = [
          "arn:aws:transfer:eu-west-2:${data.aws_caller_identity.current.account_id}:*"
        ]
      }
    ]
  })
  tags = {
    Name      = "ProductionSupport"
    Workspace = "core"
  }
}
