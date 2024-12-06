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

data "aws_iam_policy_document" "combined_sqs_policies" {
  source_policy_documents = [
    module.sqs-lg-bulk-upload-metadata-queue.sqs_policy_json,
    module.sqs-lg-bulk-upload-invalid-queue.sqs_policy_json,
    module.sqs-nrl-queue.sqs_policy_json
  ]
}

resource "aws_iam_policy" "lambda_sqs_combined_policy" {
  name        = "${terraform.workspace}-lambda-sqs-combined-policy"
  description = "Combined SQS policies for Lambda"
  policy      = data.aws_iam_policy_document.combined_sqs_policies.json
}