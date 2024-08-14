variable "name" {
  type = string
}

variable "handler" {
  type = string
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "lambda_ephemeral_storage" {
  type    = number
  default = 512
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "The number of concurrent execution allowed for lambda. A value of 0 will stop lambda from running, and -1 removes any concurrency limitations. Default to -1."
  default     = -1
}

output "lambda_arn" {
  value = aws_lambda_function.lambda.arn
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "timeout" {
  value = aws_lambda_function.lambda.timeout
}

output "qualified_arn" {
  value = aws_lambda_function.lambda.qualified_arn
}