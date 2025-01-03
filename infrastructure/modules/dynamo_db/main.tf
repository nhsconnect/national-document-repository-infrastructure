resource "aws_dynamodb_table" "ndr_dynamodb_table" {
  name                        = "${terraform.workspace}_${var.table_name}"
  hash_key                    = var.hash_key
  range_key                   = var.sort_key
  billing_mode                = var.billing_mode
  stream_enabled              = var.stream_enabled
  stream_view_type            = var.stream_view_type
  deletion_protection_enabled = var.deletion_protection_enabled

  ttl {
    enabled        = var.ttl_enabled
    attribute_name = var.ttl_attribute_name
  }

  dynamic "attribute" {
    for_each = var.attributes

    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes

    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      projection_type = global_secondary_index.value.projection_type
      range_key       = lookup(global_secondary_index.value, "range_key", null)
    }
  }

  tags = {
    Name        = "${terraform.workspace}_${var.table_name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_enabled
  }
}

resource "aws_iam_policy" "dynamodb_policy" {
  name = "${terraform.workspace}_${var.table_name}_policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        {
          Effect : "Allow",
          Action : [
            "dynamodb:Query",
            "dynamodb:Scan",
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:BatchWriteItem",
          ],
          Resource : [
            aws_dynamodb_table.ndr_dynamodb_table.arn,
          ]
        }
      ],
      length(coalesce(var.global_secondary_indexes, [])) > 0 ? [
        {
          Effect : "Allow",
          Action : [
            "dynamodb:Query",
          ],
          Resource : [
            for index in var.global_secondary_indexes :
            "${aws_dynamodb_table.ndr_dynamodb_table.arn}/index/${index.name}"
          ]
        }
      ] : []
    )
  })
}

data "aws_iam_policy_document" "dynamodb_read_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:GetItem",
    ]
    resources = [
      aws_dynamodb_table.ndr_dynamodb_table.arn,
    ]
  }

  dynamic "statement" {
    for_each = var.global_secondary_indexes
    content {
      effect    = "Allow"
      actions   = ["dynamodb:Query"]
      resources = ["${aws_dynamodb_table.ndr_dynamodb_table.arn}/index/${statement.value.name}"]
    }
  }
}

data "aws_iam_policy_document" "dynamodb_write_policy" {
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:BatchWriteItem"
    ]
    resources = [
      aws_dynamodb_table.ndr_dynamodb_table.arn,
    ]
  }
}