variable "name" {
  description = "Name of SSM parameter"
  type        = string
  default     = null
}

variable "value" {
  description = "Value of the parameter"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the parameter"
  type        = string
  default     = null
}

variable "type" {
  description = "Valid types are String, StringList and SecureString."
  type        = string
  default     = "SecureString"
}

variable "resource_depends_on" {
  description = "Optional resource to depend on before creating the SSM parameter."
  default     = ""
}

# Tags
variable "environment" {
  description = "Environment tag used for classifying the SSM parameter."
  type        = string
}

variable "owner" {
  description = "Owner tag used to identify the team or individual responsible for the resource."
  type        = string
}
