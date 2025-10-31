variable "api_gateway_id" {
  description = "ID of the existing API Gateway REST API."
  type        = string
}

variable "parent_id" {
  description = "ID of the parent API Gateway resource (e.g., root path or another nested resource)."
  type        = string
}

variable "gateway_path" {
  description = "Sub-path to create under the parent resource (e.g., users, status)."
  type        = string
}

variable "http_methods" {
  description = "List of allowed HTTP methods for the resource (e.g., [\"GET\", \"POST\"])."
  type        = list(string)
}

variable "authorization" {
  description = "Authorization type for the method (e.g., NONE, AWS_IAM, CUSTOM)."
  type        = string
}

variable "authorizer_id" {
  description = "Required resource id when setting authorization to 'CUSTOM'."
  type        = string
  default     = ""
}

variable "require_credentials" {
  description = "Sets the value of 'Access-Control-Allow-Credentials' which controls whether auth cookies are needed."
  type        = bool
}

variable "origin" {
  description = "Allowed origin for CORS requests (e.g., '*', or specific domain)."
  type        = string
  default     = "'*'"
}

variable "api_key_required" {
  description = "Whether an API key is required to access this resource."
  type        = bool
  default     = false
}

variable "request_parameters" {
  description = "Request parameters for the API Gateway method."
  type        = map(string)
  default     = {}
}
