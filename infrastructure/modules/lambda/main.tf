resource "aws_lambda_function" "lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename         = data.archive_file.lambda.output_path
  function_name    = "${terraform.workspace}_${var.name}"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = var.handler
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.11"
  timeout          = var.lambda_timeout
  memory_size      = var.memory_size

  environment {
    variables = var.lambda_environment_variables
  }
}

resource "aws_api_gateway_integration" "lambda_integration" {
  count                   = var.is_gateway_integration_needed ? 1 : 0
  rest_api_id             = var.rest_api_id
  resource_id             = var.resource_id
  http_method             = var.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_lambda_permission" "lambda_permission" {
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

resource "aws_iam_role_policy_attachment" "lambda_execution_policy" {
  count      = length(var.iam_role_policies)
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = var.iam_role_policies[count.index]
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "placeholder_lambda.py"
  output_path = "placeholder_lambda_payload.zip"
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "timeout" {
  value = aws_lambda_function.lambda.timeout
}

output "endpoint" {
  value = aws_lambda_function.lambda.arn
}