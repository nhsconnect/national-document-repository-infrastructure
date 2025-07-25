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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.ndr_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_policy.dynamodb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.dynamodb_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dynamodb_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | List of nested attribute definitions. | `list(map(string))` | `[]` | no |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | DynamoDB billing mode (e.g., PAY\_PER\_REQUEST). | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_deletion_protection_enabled"></a> [deletion\_protection\_enabled](#input\_deletion\_protection\_enabled) | Prevents table from accidental deletion. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment tag used for naming and labeling (e.g., dev, prod). | `string` | n/a | yes |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | List of optional Global Secondary Indexes. | `any` | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | Primary partition key for the table. | `string` | `null` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Identifies the team or person responsible for the resource (used for tagging). | `string` | n/a | yes |
| <a name="input_point_in_time_recovery_enabled"></a> [point\_in\_time\_recovery\_enabled](#input\_point\_in\_time\_recovery\_enabled) | Enables PITR for backups. | `bool` | `false` | no |
| <a name="input_sort_key"></a> [sort\_key](#input\_sort\_key) | Optional sort key for composite primary key. | `string` | `null` | no |
| <a name="input_stream_enabled"></a> [stream\_enabled](#input\_stream\_enabled) | Whether DynamoDB Streams are enabled. | `bool` | `false` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | Type of stream view (e.g., OLD\_IMAGE). | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Name of the DynamoDB table. | `string` | `null` | no |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | Name of the TTL attribute. | `string` | `""` | no |
| <a name="input_ttl_enabled"></a> [ttl\_enabled](#input\_ttl\_enabled) | Whether to enable TTL (Time to Live) on items. | `bool` | `false` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dynamodb_policy"></a> [dynamodb\_policy](#output\_dynamodb\_policy) | n/a |
| <a name="output_dynamodb_read_policy_document"></a> [dynamodb\_read\_policy\_document](#output\_dynamodb\_read\_policy\_document) | n/a |
| <a name="output_dynamodb_stream_arn"></a> [dynamodb\_stream\_arn](#output\_dynamodb\_stream\_arn) | n/a |
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | n/a |
| <a name="output_dynamodb_write_policy_document"></a> [dynamodb\_write\_policy\_document](#output\_dynamodb\_write\_policy\_document) | n/a |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | n/a |
<!-- END_TF_DOCS -->
