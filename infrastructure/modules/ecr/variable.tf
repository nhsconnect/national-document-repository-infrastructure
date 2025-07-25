variable "app_name" {
  description = " Name of the application (used in repository naming)."
  type        = string
}

variable "environment" {
  description = "Deployment environment tag used for naming and labeling (e.g., dev, prod)."
  type        = string
}

variable "owner" {
  description = "Identifies the team or person responsible for the resource (used for tagging)."
  type        = string
}

variable "current_account_id" {
  description = "AWS account ID where the repository is created."
  type        = string
}
