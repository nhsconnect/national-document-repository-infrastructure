variable "current_account_id" {
  description = "AWS account ID where the KMS key policy is applied."
  type        = string
}

variable "kms_key_name" {
  description = "Name of the KMS key to be created."
  type        = string
}

variable "kms_key_description" {
  description = "Description of the KMS key."
  type        = string
}

variable "kms_key_rotation_enabled" {
  description = "Enable automatic KMS key rotation."
  type        = bool
  default     = true
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
}

variable "owner" {
  description = "Owner tag for identifying the resource owner."
  type        = string
}

variable "service_identifiers" {
  description = "List of AWS service principal identifiers allowed to use the key (e.g., 's3.amazonaws.com')."
  type        = list(string)
}

variable "aws_identifiers" {
  description = "List of ARNs that will be granted decrypt-only access."
  type        = list(string)
  default     = []
}

variable "allow_decrypt_for_arn" {
  description = "Flag to allow generating a decrypt-only policy for specified ARNs."
  type        = bool
  default     = false
}

variable "allowed_arn" {
  description = "List of ARNs that are allowed full encrypt/decrypt access to the KMS key."
  type        = list(string)
  default     = []
}

output "kms_arn" {
  value = aws_kms_key.encryption_key.arn
}

output "id" {
  value = aws_kms_key.encryption_key.id
}
