resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "${terraform.workspace}-config-recorder"
  role_arn = aws_iam_role.config_recorder_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_s3_bucket" "config_bucket" {
  bucket        = "${terraform.workspace}-config-bucket"
  force_destroy = var.is_force_destroy

  tags = {
    Name        = "${terraform.workspace}-config-bucket"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}


resource "aws_config_delivery_channel" "config_delivery_channel" {
  name           = "${terraform.workspace}-config_delivery_channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  depends_on     = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}

data "aws_iam_policy_document" "config_assume_role_policy_doc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "config_recorder_role" {
  name               = "${terraform.workspace}-awsconfig-recorder-role"
  assume_role_policy = data.aws_iam_policy_document.config_assume_role_policy_doc.json
}


data "aws_iam_policy_document" "config_bucket_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.config_bucket.arn,
      "${aws_s3_bucket.config_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "config_bucket_role_policy" {
  name   = "${terraform.workspace}-config-bucket-role-policy"
  role   = aws_iam_role.config_recorder_role.id
  policy = data.aws_iam_policy_document.config_bucket_policy_doc.json
}