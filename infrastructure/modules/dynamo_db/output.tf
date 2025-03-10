output "dynamodb_policy" {
  value = aws_iam_policy.dynamodb_policy.arn
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.ndr_dynamodb_table.arn
}

output "dynamodb_stream_arn" {
  value = aws_dynamodb_table.ndr_dynamodb_table.stream_arn
}

output "table_name" {
  value = aws_dynamodb_table.ndr_dynamodb_table.id
}

output "dynamodb_read_policy_document" {
  value = data.aws_iam_policy_document.dynamodb_read_policy.json
}

output "dynamodb_write_policy_document" {
  value = data.aws_iam_policy_document.dynamodb_write_policy.json
}

output "dynamodb_write_without_update_policy_document" {
  value = data.aws_iam_policy_document.dynamodb_write_without_update_policy.json
}