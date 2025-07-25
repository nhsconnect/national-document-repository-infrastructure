variable "account_id" {
  description = "The AWS account ID used to generate IAM policy for layer access."
  type        = string
}

variable "layer_name" {
  description = "Logical name assigned to the Lambda layer."
  type        = string
}

# Outputs
output "lambda_layer_arn" {
  value = aws_lambda_layer_version.lambda_layer.arn
}

output "lambda_layer_policy_arn" {
  value = aws_iam_policy.lambda_layer_policy.arn
}

