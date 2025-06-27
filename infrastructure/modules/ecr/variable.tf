variable "app_name" {
  description = "the name of the app"
  type        = string
}

variable "is_force_destroy" {
  type = bool
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