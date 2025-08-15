# Tag Variables
variable "environment" {
  description = "Deployment environment tag used for naming and labeling (e.g., dev, prod)."
  type        = string
}

variable "owner" {
  description = "Identifies the team or person responsible for the resource (used for tagging)."
  type        = string
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "certificate_subdomain_name_prefix" {
  description = "Prefix to add to subdomains on certification configurations, dev envs use api-{env}, prod envs use api.{env}."
  type        = string
  default     = "api-"
}

# Bucket Variables
variable "docstore_bucket_name" {
  description = "The name of the S3 bucket to store ARF documents."
  type        = string
  default     = "ndr-document-store"
}

variable "zip_store_bucket_name" {
  description = "The name of the S3 bucket used as a zip store."
  type        = string
  default     = "zip-request-store"
}

variable "staging_store_bucket_name" {
  description = "The name of the S3 bucket used as a staging store."
  type        = string
  default     = "staging-bulk-store"
}

variable "lloyd_george_bucket_name" {
  description = "The name of the S3 bucket to store Lloyd George documents."
  type        = string
  default     = "lloyd-george-store"
}

variable "pdm_document_bucket_name" {
  description = "The name of the S3 bucket to store PDM documents."
  type        = string
  default     = "pdm-document-store"
}

variable "statistical_reports_bucket_name" {
  description = "The name of the S3 bucket to store weekly generated statistical reports."
  type        = string
  default     = "statistical-reports"
}

variable "trustore_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store trusted CA's for MTLS"
  default     = "truststore"
}

variable "ca_pem_filename" {
  type        = string
  description = "Filename of the CA Truststore pem file stored in the core Truststore s3 bucket"
  default     = "nhs-main-ndr-truststore.pem"
}

# DynamoDB Table Variables

variable "pdm_dynamodb_table_name" {
  description = "The name of the DynamoDB table to be use for PDM metadata."
  type        = string
  default     = "PDMDocumentMetadata"
}

variable "docstore_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store the metadata of ARF documents."
  type        = string
  default     = "DocumentReferenceMetadata"
}

variable "lloyd_george_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store the metadata of Lloyd George documents."
  type        = string
  default     = "LloydGeorgeReferenceMetadata"
}

variable "unstitched_lloyd_george_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store the metadata of un-stitched Lloyd George documents."
  type        = string
  default     = "UnstitchedLloydGeorgeReferenceMetadata"
}

variable "cloudfront_edge_table_name" {
  description = "The name of the DynamoDB table to store the presigned url reference of CloudFront requests."
  type        = string
  default     = "CloudFrontEdgeReference"
}

variable "zip_store_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store metadata related to zip file storage."
  type        = string
  default     = "ZipStoreReferenceMetadata"
}

variable "stitch_metadata_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store metadata related to LG stitching jobs ."
  type        = string
  default     = "LloydGeorgeStitchJobMetadata"
}

variable "auth_state_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store the state values (for CIS2 authorisation)."
  type        = string
  default     = "AuthStateReferenceMetadata"
}

variable "auth_session_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store user login sessions."
  type        = string
  default     = "AuthSessionReferenceMetadata"
}

variable "bulk_upload_report_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store bulk upload status."
  type        = string
  default     = "BulkUploadReport"
}

variable "statistics_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store application statistics."
  type        = string
  default     = "ApplicationStatistics"
}

variable "access_audit_dynamodb_table_name" {
  description = "The name of the DynamoDB table to store the audit of access to deceased patient records."
  type        = string
  default     = "AccessAudit"
}

variable "alarm_state_history_table_name" {
  description = "The name of the DynamoDB table to store the history of recent alarms that have been triggered."
  type        = string
  default     = "AlarmStateHistory"
}

# VPC Variables

variable "standalone_vpc_tag" {
  description = "This is the tag assigned to the standalone VPC that should be created manaully before the first run of the infrastructure."
  type        = string
}

variable "standalone_vpc_ig_tag" {
  description = "This is the tag assigned to the standalone VPC internet gateway that should be created manaully before the first run of the infrastructure."
  type        = string
}

variable "availability_zones" {
  description = "This is a list that specifies all the Availability Zones that will have a pair of public and private subnets."
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "num_public_subnets" {
  description = "Sets the number of public subnets, one per availability zone."
  type        = number
  default     = 3
}

variable "num_private_subnets" {
  description = "Sets the number of private subnets, one per availability zone."
  type        = number
  default     = 3
}

variable "enable_private_routes" {
  description = "Controls whether the internet gateway can connect to private subnets."
  type        = bool
  default     = false
}

variable "enable_dns_support" {
  description = "Enable DNS support for VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames for VPC."
  type        = bool
  default     = true
}

variable "domain" {
  description = "Used to set base level domain."
  type        = string
}

variable "certificate_domain" {
  description = "The full domain name used to request the SSL/TLS certificate (e.g. 'example.com' or 'dev.example.com')."
  type        = string
}

variable "cloud_only_service_instances" {
  description = "Number of cloud-only service instances; used to conditionally include trusted principals for IAM roles."
  type        = number
  default     = 1
}

variable "apim_environment" {}

locals {
  is_sandbox       = !contains(["ndr-dev", "ndr-test", "pre-prod", "prod"], terraform.workspace)
  is_production    = contains(["pre-prod", "prod"], terraform.workspace)
  is_force_destroy = !local.is_production

  bulk_upload_lambda_concurrent_limit = 5

  api_gateway_subdomain_name        = contains(["prod"], terraform.workspace) ? "${var.certificate_subdomain_name_prefix}" : "${var.certificate_subdomain_name_prefix}${terraform.workspace}"
  api_gateway_full_domain_name      = contains(["prod"], terraform.workspace) ? "${var.certificate_subdomain_name_prefix}${var.domain}" : "${var.certificate_subdomain_name_prefix}${terraform.workspace}.${var.domain}"
  mtls_api_gateway_subdomain_name   = contains(["prod"], terraform.workspace) ? "mtls.${var.certificate_subdomain_name_prefix}" : "mtls.${var.certificate_subdomain_name_prefix}${terraform.workspace}"
  mtls_api_gateway_full_domain_name = contains(["prod"], terraform.workspace) ? "mtls.${var.domain}" : "mtls.${terraform.workspace}.${var.domain}"


  current_region     = data.aws_region.current.name
  current_account_id = data.aws_caller_identity.current.account_id

  apim_api_url = "https://${var.apim_environment}api.service.nhs.uk/national-document-repository"
}

variable "nrl_api_endpoint_suffix" {
  description = "Constructs NRL API URL, using int. prefix if not in production."
  type        = string
  default     = "api.service.nhs.uk/record-locator/producer/FHIR/R4/DocumentReference"
}

# Virus scanner variables

variable "cloud_security_email_param_environment" {
  description = "This is the environment reference in cloud security email param store key."
  type        = string
}

variable "cloud_security_console_black_hole_address" {
  description = "Using reserved address that does not lead anywhere to make sure CloudStorageSecurity console is not available."
  type        = string
  default     = "198.51.100.0/24"
}

variable "cloud_security_console_public_address" {
  description = "Using public address to make sure CloudStorageSecurity console is available."
  type        = string
  default     = "0.0.0.0/0"
}

variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing for the API Gateway stage."
  type        = bool
  default     = false
}
