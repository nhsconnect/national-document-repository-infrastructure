variable "name" {
  description = "Unique name for the Lambda function."
  type        = string
}

variable "handler" {
  description = "Handler function in the code package (e.g., 'index.handler')."
  type        = string
}

variable "memory_size" {
  description = "Amount of memory (in MB) to allocate to the Lambda function."
  type        = number
  default     = 128
}

variable "lambda_ephemeral_storage" {
  description = "Amount of ephemeral storage (in MB) allocated to the Lambda function."
  type        = number
  default     = 512
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "The number of concurrent execution allowed for lambda. A value of 0 will stop lambda from running, and -1 removes any concurrency limitations. Default to -1."
  default     = -1
}

variable "bucket_name" {
  description = "The name of the S3 bucket the Lambda will proxy requests to."
  type        = string
}

variable "table_name" {
  description = "The name of the DynamoDB table used by the Lambda function."
  type        = string
}

variable "iam_role_policy_documents" {
  description = "List of IAM policy document ARNs to attach to the Lambda execution role."
  type        = list(string)
  default     = []
}

variable "default_policies" {
  description = "List of default IAM policy ARNs to attach to the Lambda execution role."
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole",
  ]
}
