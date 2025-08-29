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

