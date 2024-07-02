variable "name" {
  type = string
}

variable "handler" {
  type = string
}

variable "lambda_environment_variables" {
  type    = map(string)
  default = {}
}

variable "rest_api_id" {
  type = string
}

variable "resource_id" {
  type    = string
  default = ""
}

variable "is_gateway_integration_needed" {
  type        = bool
  default     = true
  description = "Indicate whether the lambda need an aws_api_gateway_integration resource block"
}

variable "is_invoked_from_gateway" {
  type        = bool
  default     = true
  description = "Indicate whether the lambda is supposed to be invoked by API gateway. Should be true for authoriser lambda."
}

variable "http_methods" {
  type    = list(string)
  default = []
}

variable "api_execution_arn" {
  type = string
}

variable "iam_role_policies" {
  type = list(string)
}

variable "lambda_timeout" {
  type    = number
  default = 30
}

variable "lambda_ephemeral_storage" {
  type    = number
  default = 512
}

variable "memory_size" {
  type    = number
  default = 128
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "The number of concurrent execution allowed for lambda. A value of 0 will stop lambda from running, and -1 removes any concurrency limitations. Default to -1."
  default     = -1
}

output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
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