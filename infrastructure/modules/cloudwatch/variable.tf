variable "cloudwatch_log_group_name" {
  description = "Name of the Cloudwatch log group"
  type        = string
  default     = null
}

variable "cloudwatch_log_steam_name" {
  description = "Name of the Cloudwatch log stream"
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "Name of the Cloudwatch log group"
  type        = number
  default     = 3
}


variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.ndr_cloudwatch_log_group.arn
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.ndr_cloudwatch_log_group.name
}
