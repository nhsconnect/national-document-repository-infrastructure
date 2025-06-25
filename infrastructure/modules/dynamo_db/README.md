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

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_dynamodb_table.ndr_dynamodb_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table)                 | resource    |
| [aws_iam_policy.dynamodb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                            | resource    |
| [aws_iam_policy_document.dynamodb_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)  | data source |
| [aws_iam_policy_document.dynamodb_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name                                                                                                                        | Description                          | Type                | Default                | Required |
| --------------------------------------------------------------------------------------------------------------------------- | ------------------------------------ | ------------------- | ---------------------- | :------: |
| <a name="input_attributes"></a> [attributes](#input_attributes)                                                             | List of nested attribute definitions | `list(map(string))` | `[]`                   |    no    |
| <a name="input_billing_mode"></a> [billing_mode](#input_billing_mode)                                                       | n/a                                  | `string`            | `"PAY_PER_REQUEST"`    |    no    |
| <a name="input_deletion_protection_enabled"></a> [deletion_protection_enabled](#input_deletion_protection_enabled)          | n/a                                  | `bool`              | `null`                 |    no    |
| <a name="input_environment"></a> [environment](#input_environment)                                                          | n/a                                  | `string`            | n/a                    |   yes    |
| <a name="input_global_secondary_indexes"></a> [global_secondary_indexes](#input_global_secondary_indexes)                   | n/a                                  | `any`               | `[]`                   |    no    |
| <a name="input_hash_key"></a> [hash_key](#input_hash_key)                                                                   | n/a                                  | `string`            | `null`                 |    no    |
| <a name="input_owner"></a> [owner](#input_owner)                                                                            | n/a                                  | `string`            | n/a                    |   yes    |
| <a name="input_point_in_time_recovery_enabled"></a> [point_in_time_recovery_enabled](#input_point_in_time_recovery_enabled) | n/a                                  | `bool`              | `false`                |    no    |
| <a name="input_sort_key"></a> [sort_key](#input_sort_key)                                                                   | n/a                                  | `string`            | `null`                 |    no    |
| <a name="input_stream_enabled"></a> [stream_enabled](#input_stream_enabled)                                                 | n/a                                  | `bool`              | `false`                |    no    |
| <a name="input_stream_view_type"></a> [stream_view_type](#input_stream_view_type)                                           | n/a                                  | `string`            | `"NEW_AND_OLD_IMAGES"` |    no    |
| <a name="input_table_name"></a> [table_name](#input_table_name)                                                             | Name of the DynamoDB table           | `string`            | `null`                 |    no    |
| <a name="input_ttl_attribute_name"></a> [ttl_attribute_name](#input_ttl_attribute_name)                                     | n/a                                  | `string`            | `""`                   |    no    |
| <a name="input_ttl_enabled"></a> [ttl_enabled](#input_ttl_enabled)                                                          | n/a                                  | `bool`              | `false`                |    no    |

## Outputs

| Name                                                                                                                          | Description |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_dynamodb_policy"></a> [dynamodb_policy](#output_dynamodb_policy)                                              | n/a         |
| <a name="output_dynamodb_read_policy_document"></a> [dynamodb_read_policy_document](#output_dynamodb_read_policy_document)    | n/a         |
| <a name="output_dynamodb_stream_arn"></a> [dynamodb_stream_arn](#output_dynamodb_stream_arn)                                  | n/a         |
| <a name="output_dynamodb_table_arn"></a> [dynamodb_table_arn](#output_dynamodb_table_arn)                                     | n/a         |
| <a name="output_dynamodb_write_policy_document"></a> [dynamodb_write_policy_document](#output_dynamodb_write_policy_document) | n/a         |
| <a name="output_table_name"></a> [table_name](#output_table_name)                                                             | n/a         |

<!-- END_TF_DOCS -->
