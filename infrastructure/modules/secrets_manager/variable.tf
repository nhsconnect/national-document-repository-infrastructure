variable "name" {
  description = "Name of Secrets Manager secret"
  type        = string
  default     = null
}

variable "description" {
  description = "Description of the secret"
  type        = string
  default     = null
}

variable "resource_depends_on" {
  default = ""
}

# Tags
variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

output "secret_name" {
  value = aws_secretsmanager_secret.secret.name
}

output "read_access_policy" {
  value = aws_iam_policy.allow_read_secret.arn
}
