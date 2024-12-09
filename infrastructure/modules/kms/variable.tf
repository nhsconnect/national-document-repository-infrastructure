variable "current_account_id" {
  type = string
}

variable "kms_key_name" {
  type = string
}

variable "kms_key_description" {
  type = string
}

variable "kms_key_rotation_enabled" {
  type    = bool
  default = true
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "service_identifiers" {
  type = list(string)
}

variable "aws_identifiers" {
  type    = list(string)
  default = []
}

variable "allow_decrypt_for_arn" {
  type    = bool
  default = false
}

variable "allowed_arn" {
  type    = list(string)
  default = []
}

output "kms_arn" {
  value = aws_kms_key.encryption_key.arn
}

output "id" {
  value = aws_kms_key.encryption_key.id
}
