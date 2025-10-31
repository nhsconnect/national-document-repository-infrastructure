resource "aws_backup_plan" "cross_account_backup_schedule" {
  name = "${terraform.workspace}-cross-account-backup-plan"

  count = local.is_production ? 1 : 0

  rule {
    rule_name         = "CrossAccount6pmBackup"
    target_vault_name = aws_backup_vault.backup_vault.name
    schedule          = "cron(0 18 * * ? *)"
    copy_action {
      destination_vault_arn = data.aws_ssm_parameter.target_backup_vault_arn.value
      lifecycle {
        delete_after       = 35
        cold_storage_after = 0
      }

    }
  }
}

data "aws_ssm_parameter" "target_backup_vault_arn" {
  name = "backup-target-vault-arn"
}

data "aws_ssm_parameter" "backup_target_account" {
  name = "backup-target-account"
}

resource "aws_iam_policy" "copy_policy" {
  name  = "${terraform.workspace}_cross_account_copy_policy"
  count = local.is_production ? 1 : 0

  description = "Permissions required to copy to another accounts backup vault"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : ["backup:CopyIntoBackupVault"],
      "Resource" : data.aws_ssm_parameter.target_backup_vault_arn.value
    }]
  })
}
resource "aws_iam_role_policy_attachment" "cross_account_copy_policy" {
  count      = local.is_production ? 1 : 0
  role       = aws_iam_role.cross_account_backup_iam_role[0].name
  policy_arn = aws_iam_policy.copy_policy[0].arn
}

resource "aws_backup_selection" "cross_account_backup_selection" {
  count        = local.is_production ? 1 : 0
  iam_role_arn = aws_iam_role.cross_account_backup_iam_role[0].arn
  name         = "${terraform.workspace}_cross_account_backup_selection"
  plan_id      = aws_backup_plan.cross_account_backup_schedule[0].id

  resources = [
    module.ndr-document-store.bucket_arn,
    module.ndr-lloyd-george-store.bucket_arn,
    module.document_reference_dynamodb_table.dynamodb_table_arn,
    module.lloyd_george_reference_dynamodb_table.dynamodb_table_arn,
    module.bulk_upload_report_dynamodb_table.dynamodb_table_arn,
    module.statistical-reports-store.bucket_arn,
    module.pdm_dynamodb_table.dynamodb_table_arn,
    module.pdm-document-store.bucket_arn,
    module.ndr-configs-store.bucket_arn
  ]
}

resource "aws_iam_role" "cross_account_backup_iam_role" {
  count              = local.is_production ? 1 : 0
  name               = "${terraform.workspace}_cross_account_backup_iam_role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cross_account_backup_policy" {
  count      = local.is_production ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.cross_account_backup_iam_role[0].name
  depends_on = [aws_iam_role.cross_account_backup_iam_role]
}

resource "aws_iam_role_policy_attachment" "cross_account_restore_policy" {
  count      = local.is_production ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.cross_account_backup_iam_role[0].name
  depends_on = [aws_iam_role.cross_account_backup_iam_role]
}

resource "aws_iam_role_policy_attachment" "cross_account_s3_backup_policy" {
  count      = local.is_production ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.cross_account_backup_iam_role[0].name
  depends_on = [aws_iam_role.cross_account_backup_iam_role]
}

resource "aws_iam_role_policy_attachment" "s3_cross_account_restore_policy" {
  count      = local.is_production ? 1 : 0
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  role       = aws_iam_role.cross_account_backup_iam_role[0].name
  depends_on = [aws_iam_role.cross_account_backup_iam_role]
}
