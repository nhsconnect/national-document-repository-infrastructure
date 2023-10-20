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

variable "http_method" {
  type    = string
  default = "GET"
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

output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
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