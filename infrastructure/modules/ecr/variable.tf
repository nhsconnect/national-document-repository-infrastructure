variable "app_name" {
  description = "the name of the app"
  type        = string
}

variable "allow_force_destroy" {
  description = "Enable force destroy of the ECR module"
  type        = bool
  default     = false
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "current_account_id" {
  type = string
}