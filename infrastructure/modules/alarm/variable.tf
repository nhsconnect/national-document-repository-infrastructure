
variable "namespace" {
  type    = string
  default = "AWS/Lambda"
}

variable "lambda_function_name" {
  type = string
}

variable "lambda_name" {
  type = string
}
variable "alarm_actions" {
  type = list(string)
}

variable "ok_actions" {
  type = list(string)
}

variable "lambda_timeout" {
  type = number
}