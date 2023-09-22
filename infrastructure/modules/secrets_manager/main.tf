resource "aws_secretsmanager_secret" "secret" {
  name        = "/ndr/${terraform.workspace}/${var.name}"
  description = var.description
  depends_on  = [var.resource_depends_on]
  tags = {
    Name        = "${terraform.workspace}-secretsmanager"
    Environment = var.environment
    Workspace   = terraform.workspace
    Owner       = var.owner
  }
}


resource "aws_iam_policy" "allow_read_secret" {
  name = "${terraform.workspace}_${var.name}_read_access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [
          aws_secretsmanager_secret.secret.arn,
        ]
      }
    ]
  })
}