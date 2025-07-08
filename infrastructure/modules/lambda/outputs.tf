output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "qualified_arn" {
  value = aws_lambda_function.lambda.qualified_arn
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "timeout" {
  value = aws_lambda_function.lambda.timeout
}

output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}

output "lambda_execution_role_name" {
  value = aws_iam_role.lambda_execution_role.name
}

output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_execution_role.arn
}