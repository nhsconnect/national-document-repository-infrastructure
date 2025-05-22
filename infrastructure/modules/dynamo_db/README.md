# DynamoDB Table Module

This Terraform module provisions a highly configurable AWS DynamoDB table for scalable, low-latency key-value storage. It supports TTL, streams, backups, IAM policies, and optional global secondary indexes — ideal for serverless and event-driven workloads.

---

## Features

- [x] Configurable table name, hash key, and optional sort key
- [x] TTL (Time To Live) for auto-expiring items
- [x] Streams for Lambda or change tracking integration
- [x] Point-in-time recovery (automated backups)
- [x] Optional Global Secondary Indexes (GSIs)
- [x] IAM policy documents for read and write permissions
- [x] Optional deletion protection
- [x] Full environment and owner tagging

---

## Usage

```hcl
module "dynamodb_table" {
  source = "./modules/dynamodb"

  # Required context
  environment = "prod"
  owner       = "platform"

  # Table naming and schema
  table_name  = "my-table"
  hash_key    = "user_id"
  sort_key    = "created_at"

  # Attribute definitions
  attributes = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "created_at"
      type = "N"
    },
    {
      name = "expires_at"
      type = "N"
    }
  ]

  # Provisioning and scaling
  billing_mode                   = "PAY_PER_REQUEST"
  point_in_time_recovery_enabled = true

  # Time-to-live settings
  ttl_enabled         = true
  ttl_attribute_name  = "expires_at"

  # Stream configuration
  stream_enabled     = true
  stream_view_type   = "NEW_AND_OLD_IMAGES"

  # Optional global secondary indexes
  global_secondary_indexes = [
    {
      name            = "user-by-date"
      hash_key        = "user_id"
      sort_key        = "created_at"
      projection_type = "ALL"
    }
  ]
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
