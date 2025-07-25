variable "name" {
  type = string

  validation {
    condition     = length(var.name) < 34
    error_message = "The lambda name cannot be longer than 33 characters as this breaks the IAM role name limit"
  }
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

variable "iam_role_policy_documents" {
  type    = list(string)
  default = []
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
  default = 512
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "The number of concurrent execution allowed for lambda. A value of 0 will stop lambda from running, and -1 removes any concurrency limitations. Default to -1."
  default     = -1
}

variable "default_policies" {
  default = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
    "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
  ]
}

variable "non_persistent_workspaces" {
  type        = list(string)
  description = "A list of workspaces that do not require persistent logs"
  default     = ["ndr-dev", "ndra", "ndrb", "ndrc", "ndrd"]
}

variable "default_lambda_layers" {
  type = list(string)
  default = [
    "arn:aws:lambda:eu-west-2:282860088358:layer:AWS-AppConfig-Extension:120"
  ]
}

variable "extra_lambda_layers" {
  type    = list(string)
  default = ["arn:aws:lambda:eu-west-2:580247275435:layer:LambdaInsightsExtension:53"]
}
