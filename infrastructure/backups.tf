resource "aws_backup_vault" "backup_vault" {
  name          = "${terraform.workspace}_backup_vault"
  force_destroy = local.is_sandbox
}

resource "aws_backup_plan" "s3_continuous_backup" {
  name = "${terraform.workspace}_s3_continuous_backup"

  rule {
    enable_continuous_backup = !local.is_sandbox
    rule_name                = "S3BucketContinousBackups"
    schedule                 = "cron(0 5 ? * * *)" # Required due to bug in AWS provider https://github.com/hashicorp/terraform-provider-aws/issues/23976
    target_vault_name        = aws_backup_vault.backup_vault.name
    lifecycle {
      cold_storage_after = 0
      delete_after       = 35
    }
  }
}

resource "aws_backup_selection" "s3_continuous_backup" {
  iam_role_arn = aws_iam_role.s3_backup_iam_role.arn
  name         = "${terraform.workspace}_s3_continuous_backup_selection"
  plan_id      = aws_backup_plan.s3_continuous_backup.id

  resources = [
    module.ndr-document-store.bucket_arn,
    module.ndr-lloyd-george-store.bucket_arn,
    module.statistical-reports-store.bucket_arn,
    module.ndr-configs-store.bucket_arn
  ]
}


data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_backup_iam_role" {
  name               = "${terraform.workspace}_s3_backup_iam_role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = aws_iam_role.s3_backup_iam_role.name
  depends_on = [aws_iam_role.s3_backup_iam_role]
}

resource "aws_iam_role_policy_attachment" "restore_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
  role       = aws_iam_role.s3_backup_iam_role.name
  depends_on = [aws_iam_role.s3_backup_iam_role]
}

resource "aws_iam_role_policy_attachment" "s3_backup_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Backup"
  role       = aws_iam_role.s3_backup_iam_role.name
  depends_on = [aws_iam_role.s3_backup_iam_role]
}

resource "aws_iam_role_policy_attachment" "s3_restore_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSBackupServiceRolePolicyForS3Restore"
  role       = aws_iam_role.s3_backup_iam_role.name
  depends_on = [aws_iam_role.s3_backup_iam_role]
}


