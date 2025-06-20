# Tag Variables
variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "certificate_subdomain_name_prefix" {
  type        = string
  description = "Prefix to add to subdomains on certification configurations, dev envs use api-{env}, prod envs use api.{env}"
  default     = "api-"
}

# Bucket Variables
variable "docstore_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store ARF documents"
  default     = "ndr-document-store"
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
  description = "The name of the S3 bucket to store Lloyd George documents"
  default     = "lloyd-george-store"
}

variable "pdm_document_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store PDM documents"
  default     = "pdm-document-store"
}

variable "statistical_reports_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store weekly generated statistical reports"
  default     = "statistical-reports"
}

# DynamoDB Table Variables

variable "pdm_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to be use for pdm metadata"
  default     = "pdm_document_metadata"
}

variable "docstore_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to store the metadata of ARF documents"
  default     = "DocumentReferenceMetadata"
}

variable "lloyd_george_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to store the metadata of Lloyd George documents"
  default     = "LloydGeorgeReferenceMetadata"
}

variable "unstitched_lloyd_george_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to store the metadata of un-stitched Lloyd George documents"
  default     = "UnstitchedLloydGeorgeReferenceMetadata"
}

variable "cloudfront_edge_table_name" {
  type        = string
  description = "The name of the dynamodb table to store the presigned url reference of CloudFront requests"
  default     = "CloudFrontEdgeReference"
}

variable "zip_store_dynamodb_table_name" {
  type    = string
  default = "ZipStoreReferenceMetadata"
}

variable "stitch_metadata_dynamodb_table_name" {
  type    = string
  default = "LloydGeorgeStitchJobMetadata"
}

variable "auth_state_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to store the state values (for CIS2 authorisation)"
  default     = "AuthStateReferenceMetadata"
}

variable "auth_session_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to store user login sessions"
  default     = "AuthSessionReferenceMetadata"
}

variable "bulk_upload_report_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to store bulk upload status"
  default     = "BulkUploadReport"
}

variable "statistics_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to store application statistics"
  default     = "ApplicationStatistics"
}

variable "access_audit_dynamodb_table_name" {
  type        = string
  description = "The name of the dynamodb table to store the audit of access to deceased patient records"
  default     = "AccessAudit"
}

# VPC Variables

variable "standalone_vpc_tag" {
  type        = string
  description = "This is the tag assigned to the standalone vpc that should be created manaully before the first run of the infrastructure"
}

variable "standalone_vpc_ig_tag" {
  type        = string
  description = "This is the tag assigned to the standalone vpc internet gateway that should be created manaully before the first run of the infrastructure"
}

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

variable "cloud_only_service_instances" {
  type    = number
  default = 1
}

variable "poll_frequency" {}

variable "cloudwatch_alarm_evaluation_periods" {}

variable "apim_environment" {}

locals {
  is_sandbox         = contains(["ndra", "ndrb", "ndrc", "ndrd"], terraform.workspace)
  is_production      = contains(["pre-prod", "prod"], terraform.workspace)
  is_force_destroy   = contains(["ndr-dev", "ndra", "ndrb", "ndrc", "ndrd", "ndr-test"], terraform.workspace)
  is_sandbox_or_test = contains(["ndra", "ndrb", "ndrc", "ndrd", "ndr-test"], terraform.workspace)

  bulk_upload_lambda_concurrent_limit = 5

  api_gateway_subdomain_name   = contains(["prod"], terraform.workspace) ? "${var.certificate_subdomain_name_prefix}" : "${var.certificate_subdomain_name_prefix}${terraform.workspace}"
  api_gateway_full_domain_name = contains(["prod"], terraform.workspace) ? "${var.certificate_subdomain_name_prefix}${var.domain}" : "${var.certificate_subdomain_name_prefix}${terraform.workspace}.${var.domain}"

  current_region     = data.aws_region.current.name
  current_account_id = data.aws_caller_identity.current.account_id

  apim_api_url = "https://${var.apim_environment}api.service.nhs.uk/national-document-repository"
}

variable "nrl_api_endpoint_suffix" {
  default = "api.service.nhs.uk/record-locator/producer/FHIR/R4/DocumentReference"
}

# Virus scanner variables

variable "cloud_security_email_param_environment" {
  type        = string
  description = "This is the environment reference in cloud security email param store key"
}

variable "cloud_security_console_black_hole_address" {
  type        = string
  default     = "198.51.100.0/24"
  description = "Using reserved address that does not lead anywhere to make sure CloudStorageSecurity console is not available"
}

variable "cloud_security_console_public_address" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Using public address to make sure CloudStorageSecurity console is available"
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing for the API Gateway stage"
  type        = bool
  default     = false
}
