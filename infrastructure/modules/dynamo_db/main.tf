resource "aws_dynamodb_table" "ndr_dynamodb_table" {
  name                        = "${terraform.workspace}_${var.table_name}"
  hash_key                    = var.hash_key
  billing_mode                = var.billing_mode
  stream_enabled              = var.stream_enabled
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
    }
  }

  tags = {
    Name        = "${terraform.workspace}_${var.table_name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}
resource "aws_iam_policy" "dynamodb_policy" {
  name = "${terraform.workspace}_${var.table_name}_policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:Query",
        ],
        "Resource" : [
          for index in var.global_secondary_indexes :
          "${aws_dynamodb_table.ndr_dynamodb_table.arn}/index/${index.name}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
        ],
        "Resource" : [
          aws_dynamodb_table.ndr_dynamodb_table.arn,
        ]
      }

    ]
  })
}