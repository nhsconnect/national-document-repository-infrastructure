resource "aws_lambda_function" "lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename                       = data.archive_file.lambda.output_path
  function_name                  = "${terraform.workspace}_${var.name}"
  role                           = aws_iam_role.lambda_execution_role.arn
  handler                        = var.handler
  source_code_hash               = data.archive_file.lambda.output_base64sha256
  runtime                        = "python3.11"
  timeout                        = var.lambda_timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  kms_key_arn                    = aws_kms_key.lambda.arn

  ephemeral_storage {
    size = var.lambda_ephemeral_storage
  }

  environment {
    variables = var.lambda_environment_variables
  }

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = var.vpc_security_group_ids
  }

  layers = local.lambda_layers

  lifecycle {
    ignore_changes = [
      # These are required as Lambdas are deployed via the CI/CD pipelines
      source_code_hash,
      layers
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.default_policies,
    aws_iam_role_policy_attachment.lambda_execution_policy
  ]
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  count             = contains(var.persistent_workspaces, terraform.workspace) ? 0 : 1
  name              = "/aws/lambda/${terraform.workspace}_${var.name}"
  retention_in_days = 1
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "root_kms_access" {
  statement {
    sid    = "AllowRootAccountAccess"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions = [
      "kms:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowLambdaExecutionRole"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        aws_iam_role.lambda_execution_role.arn
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "lambda_kms_access" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = [
      aws_kms_key.lambda.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_kms_access" {
  name   = "lambda_kms_usage"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_kms_access.json
}

resource "aws_kms_key" "lambda" {
  deletion_window_in_days = var.kms_deletion_window
  description             = "Custom KMS Key for ${terraform.workspace}_${var.name}"
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.root_kms_access.json
}

resource "aws_kms_alias" "lambda" {
  name          = "alias/${terraform.workspace}_${var.name}"
  target_key_id = aws_kms_key.lambda.key_id
}

resource "aws_api_gateway_integration" "lambda_integration" {
  for_each                = var.is_gateway_integration_needed ? { for idx, method in var.http_methods : idx => method } : {}
  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  http_method             = each.value
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_lambda_permission" "lambda_permission" {
  count         = var.is_invoked_from_gateway ? 1 : 0
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${var.api_execution_arn}/*/*"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "${terraform.workspace}_lambda_execution_role_${var.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "merged_policy" {
  source_policy_documents = concat(var.iam_role_policy_documents, [data.aws_iam_policy_document.lambda_kms_access.json])
}

resource "aws_iam_policy" "combined_policies" {
  name   = "${terraform.workspace}_${var.name}_combined_policy"
  policy = data.aws_iam_policy_document.merged_policy.json
}

resource "aws_iam_role_policy_attachment" "default_policies" {
  for_each   = toset(var.default_policies)
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.combined_policies.arn
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "placeholder_lambda.py"
  output_path = "placeholder_lambda_payload.zip"
}
