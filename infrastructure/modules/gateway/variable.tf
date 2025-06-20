variable "api_gateway_id" {
  type = string
}

variable "parent_id" {
  type = string
}

variable "gateway_path" {
  type = string
}

variable "http_methods" {
  type = list(string)
}

variable "authorization" {
  type = string
}

variable "authorizer_id" {
  description = "Required resource id when setting authorization to 'CUSTOM'"
  type        = string
  default     = ""
}

variable "require_credentials" {
  description = "Sets the value of 'Access-Control-Allow-Credentials' which controls whether auth cookies are needed"
  type        = bool
}

variable "origin" {
  type    = string
  default = "'*'"
}

variable "api_key_required" {
  type    = bool
  default = false
}