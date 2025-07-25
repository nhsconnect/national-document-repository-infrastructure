variable "table_name" {
  description = "Name of the DynamoDB table."
  type        = string
  default     = null
}

variable "attributes" {
  description = "List of nested attribute definitions."
  type        = list(map(string))
  default     = []
}

variable "hash_key" {
  description = "Primary partition key for the table."
  type        = string
  default     = null
}

variable "sort_key" {
  description = "Optional sort key for composite primary key."
  type        = string
  default     = null
}

variable "billing_mode" {
  description = "DynamoDB billing mode (e.g., PAY_PER_REQUEST)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "ttl_enabled" {
  description = "Whether to enable TTL (Time to Live) on items."
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the TTL attribute."
  type        = string
  default     = ""
}

variable "global_secondary_indexes" {
  description = "List of optional Global Secondary Indexes."
  type        = any
  default     = []
}

variable "deletion_protection_enabled" {
  description = "Prevents table from accidental deletion."
  type        = bool
  default     = null
}

variable "stream_enabled" {
  description = "Whether DynamoDB Streams are enabled."
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Type of stream view (e.g., OLD_IMAGE)."
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

variable "environment" {
  description = "Deployment environment tag used for naming and labeling (e.g., dev, prod)."
  type        = string
}

variable "owner" {
  description = "Identifies the team or person responsible for the resource (used for tagging)."
  type        = string
}

variable "point_in_time_recovery_enabled" {
  description = "Enables PITR for backups."
  type        = bool
  default     = false
}
