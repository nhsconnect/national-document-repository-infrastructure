resource "aws_iam_policy" "lambda_layer_policy" {
  name = "${local.lambda_layer_aws_name}_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:GetLayerVersion",
          "lambda:ListLayerVersions",
          "lambda:ListLayers"
        ],
        Resource = [
          "arn:aws:lambda:eu-west-2:${data.aws_caller_identity.current.account_id}:layer:${local.lambda_layer_aws_name}:*"
        ]
      }
    ]
  })
}

