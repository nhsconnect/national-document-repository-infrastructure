
variable "namespace" {
  description = "CloudWatch metric namespace. Defaults to 'AWS/Lambda' if not specified."
  type        = string
  default     = "AWS/Lambda"
}

variable "lambda_function_name" {
  description = "The name of the Lambda function to monitor."
  type        = string
}

variable "lambda_name" {
  description = "Short identifier used in CloudWatch alarm naming."
  type        = string
}
variable "alarm_actions" {
  description = "List of ARNs (e.g., SNS topics) to notify when a CloudWatch alarm is triggered."
  type        = list(string)
}

variable "ok_actions" {
  description = "List of ARNs to notify when a CloudWatch alarm returns to the OK state."
  type        = list(string)
}

variable "lambda_timeout" {
  description = "Timeout value of the Lambda function in seconds."
  type        = number
}
