variable "environment" {
  description = "Deployment environment tag used for naming and labeling (e.g., dev, prod)"
  type        = string
}

variable "owner" {
  description = "Identifies the team or person responsible for the resource (used for tagging)."
  type        = string
}

variable "config_environment_name" {
  description = "Name of the AppConfig environment (e.g., dev, prod)."
  type        = string
}

variable "config_profile_name" {
  description = "Name of the AppConfig configuration profile."
  type        = string
}


