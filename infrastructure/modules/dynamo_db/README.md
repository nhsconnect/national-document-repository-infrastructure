# DynamoDB Table Module

## Features

- Configurable table name, hash key, and optional sort key
- TTL (Time To Live) for auto-expiring items
- Streams for Lambda or change tracking integration
- Point-in-time recovery (automated backups)
- Optional Global Secondary Indexes (GSIs)
- IAM policy documents for read and write permissions
- Optional deletion protection
- Full environment and owner tagging

---

## Usage

```hcl
module "document_reference_dynamodb_table" {
  source = "./modules/dynamo_db"

  # Table name and primary key
  table_name = var.docstore_dynamodb_table_name
  hash_key   = "ID"

  # Optional sort key
  # sort_key = "created_at"

  # Attribute definitions for the table and indexes
  attributes = [
    {
      name = "ID"
      type = "S"
    },
    {
      name = "FileLocation"
      type = "S"
    },
    {
      name = "NhsNumber"
      type = "S"
    }
  ]

  # Optional: enable TTL
  ttl_enabled        = true
  ttl_attribute_name = "TTL"

  # Optional: enable streams
  stream_enabled   = true
  stream_view_type = "OLD_IMAGE"

  # Optional: point-in-time recovery
  point_in_time_recovery_enabled = !local.is_sandbox

  # Optional: global secondary indexes
  global_secondary_indexes = [
    {
      name            = "FileLocationsIndex"
      hash_key        = "FileLocation"
      projection_type = "ALL"
    },
    {
      name            = "NhsNumberIndex"
      hash_key        = "NhsNumber"
      projection_type = "ALL"
    }
  ]

  # Context tags
  environment = var.environment
  owner       = var.owner

  # Optional: enable deletion protection
  deletion_protection_enabled = local.is_production
}


```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
