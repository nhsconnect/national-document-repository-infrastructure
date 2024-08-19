terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.11"
    }
  }
}

resource "aws_lambda_function" "lambda" {
  provider = aws # Alternative AWS provider for Lambda@Edge region

  filename                       = data.archive_file.lambda.output_path
  function_name                  = "${terraform.workspace}_${var.name}"
  role                           = aws_iam_role.lambda_exec_role.arn
  handler                        = var.handler
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  runtime                        = "python3.11"
  timeout                        = var.lambda_timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  ephemeral_storage {
    size = var.lambda_ephemeral_storage
  }
  publish = true # Publish the version for Lambda@Edge
}


data "archive_file" "lambda" {
  type        = "zip"
  source_file = "placeholder_lambda.py"
  output_path = "placeholder_lambda_payload.zip"
}

# Define the IAM role for the Lambda function with the combined assume role policy
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_edge_exec_role"

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

# TODO: Refine log resource output and add dynamic bucket name
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
  }
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  name   = "lambda_edge_exec_policy"
  role   = aws_iam_role.lambda_exec_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}


resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  count      = length(var.iam_role_policies)
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = var.iam_role_policies[count.index]
}