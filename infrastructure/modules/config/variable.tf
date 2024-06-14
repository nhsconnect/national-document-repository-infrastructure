# Tags
variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "is_force_destroy" {
  description = "(Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type        = bool
  default     = false
}
