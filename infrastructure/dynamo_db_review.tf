module "document_review_dynamodb_table" {
  source                         = "./modules/dynamo_db"
  table_name                     = var.document_review_table_name
  hash_key                       = "ID"
  deletion_protection_enabled    = local.is_production
  stream_enabled                 = false
  ttl_enabled                    = true
  ttl_attribute_name             = "TTL"
  point_in_time_recovery_enabled = !local.is_sandbox

  attributes = [
    {
      name = "ID"
      type = "S"
    },
    {
      name = "Custodian"
      type = "S"
    },
    {
      name = "NhsNumber"
      type = "S"
    },
    {
      name = "ReviewStatus"
      type = "S"
    },
    {
      name = "Author"
      type = "S"
    },
    {
      name = "Reviewer"
      type = "S"
    },
    {
      name = "ReviewDate"
      type = "S"
    },
    {
      name = "UploadDate"
      type = "N"
    }

  ]

  global_secondary_indexes = [
    {
      name            = "CustodianIndex"
      hash_key        = "Custodian"
      range_key       = "UploadDate"
      projection_type = "ALL"

    },
    {
      name            = "AuthorIndex"
      hash_key        = "Author"
      range_key       = "UploadDate"
      projection_type = "ALL"

    },
    {
      name            = "ReviewStatusIndex"
      hash_key        = "ReviewStatus"
      range_key       = "UploadDate"
      projection_type = "ALL"
    },
    {
      name            = "ReviewerIndex"
      hash_key        = "Reviewer"
      range_key       = "ReviewDate"
      projection_type = "ALL"
    },
    {
      name            = "NhsNumberIndex"
      hash_key        = "NhsNumber"
      range_key       = "UploadDate"
      projection_type = "ALL"
    }
  ]

  environment = var.environment
  owner       = var.owner
}
