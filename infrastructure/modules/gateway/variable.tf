variable "api_gateway_id" {
  type = string
}

variable "parent_id" {
  type = string
}

variable "gateway_path" {
  type = string
}

variable "http_method" {
  type = string
}

variable "authorization" {
  type = string
}

variable "authorizer_id" {
  description = "Required resource id when setting authorization to 'CUSTOM'"
  type        = string
  default     = ""
}

variable "owner" {
  type = string
}

variable "environment" {
  type = string
}

variable "require_credentials" {
  description = "Sets the value of 'Access-Control-Allow-Credentials' which controls whether auth cookies are needed"
  type        = bool
}

variable "api_execution_arn" {
  type = string
}

output "gateway_resource_id" {
  value = aws_api_gateway_resource.gateway_resource.id
}

variable "origin" {
  type = string
}