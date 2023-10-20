# Tag Variables
variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

# Bucket Variables
variable "docstore_bucket_name" {
  type        = string
  description = "The name of S3 bucket to store ARF documents"
  default     = "document-store"
}

variable "zip_store_bucket_name" {
  type    = string
  default = "zip-request-store"
}

variable "staging_store_bucket_name" {
  type    = string
  default = "staging-bulk-store"
}

variable "lloyd_george_bucket_name" {
  type        = string
  description = "The name of S3 bucket to store Lloyd George documents"
  default     = "lloyd-george-store"
}

# DynamoDB Table Variables
variable "docstore_dynamodb_table_name" {
  type        = string
  description = "The name of dynamodb table to store the metadata of ARF documents"
  default     = "DocumentReferenceMetadata"
}

variable "lloyd_george_dynamodb_table_name" {
  type        = string
  description = "The name of dynamodb table to store the metadata of Lloyd George documents"
  default     = "LloydGeorgeReferenceMetadata"
}

variable "zip_store_dynamodb_table_name" {
  type    = string
  default = "ZipStoreReferenceMetadata"
}

variable "auth_state_dynamodb_table_name" {
  type        = string
  description = "The name of dynamodb table to store the state values (for CIS2 authorisation)"
  default     = "AuthStateReferenceMetadata"
}

variable "auth_session_dynamodb_table_name" {
  type        = string
  description = "The name of dynamodb table to store user login sessions"
  default     = "AuthSessionReferenceMetadata"
}
# VPC Variables
variable "availability_zones" {
  type        = list(string)
  description = "This is a list that specifies all the Availability Zones that will have a pair of public and private subnets"
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "num_public_subnets" {
  type        = number
  description = "Sets the number of public subnets, one per availability zone"
  default     = 3
}

variable "num_private_subnets" {
  type        = number
  description = "Sets the number of private subnets, one per availability zone"
  default     = 3
}

variable "enable_private_routes" {
  type        = bool
  description = "Controls whether the internet gateway can connect to private subnets"
  default     = false
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS  support for VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames for VPC"
  default     = true
}

variable "domain" {
  type = string
}

variable "certificate_domain" {
  type = string
}
