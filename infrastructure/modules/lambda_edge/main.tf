resource "aws_lambda_function" "lambda" {
  provider = aws
  publish  = true

  filename                       = data.archive_file.lambda.output_path
  function_name                  = "${terraform.workspace}_${var.name}"
  role                           = aws_iam_role.lambda_exec_role.arn
  handler                        = var.handler
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  runtime                        = "python3.11"
  timeout                        = 5
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  ephemeral_storage {
    size = var.lambda_ephemeral_storage
  }
}


data "archive_file" "lambda" {
  type        = "zip"
  source_file = "placeholder_lambda.py"
  output_path = "placeholder_lambda_payload.zip"
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "${terraform.workspace}_lambda_edge_exec_role"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:UpdateItem",
    ]
    resources = ["arn:aws:dynamodb:eu-west-2:${data.aws_caller_identity.current.account_id}:table/${var.table_name}"]
  }
}


resource "aws_iam_role_policy" "lambda_exec_policy" {
  name   = "${terraform.workspace}_lambda_edge_exec_policy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}


resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  count      = length(var.iam_role_policies)
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = var.iam_role_policies[count.index]
}
