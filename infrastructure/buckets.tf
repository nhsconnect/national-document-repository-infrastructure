locals {
  access_logs_bucket_id = local.is_production ? aws_s3_bucket.access_logs[0].id : ""
  access_logs_count     = local.is_production ? 1 : 0
}

# Bucket Modules
module "ndr-document-store" {
  source                    = "./modules/s3/"
  access_logs_enabled       = local.is_production
  access_logs_bucket_id     = local.access_logs_bucket_id
  bucket_name               = var.docstore_bucket_name
  enable_cors_configuration = true
  enable_bucket_versioning  = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = local.is_force_destroy
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["POST", "PUT", "DELETE"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_methods = ["GET"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

module "ndr-zip-request-store" {
  source                    = "./modules/s3/"
  access_logs_enabled       = local.is_production
  access_logs_bucket_id     = local.access_logs_bucket_id
  bucket_name               = var.zip_store_bucket_name
  enable_cors_configuration = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = local.is_force_destroy
  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

module "ndr-lloyd-george-store" {
  source                    = "./modules/s3/"
  access_logs_enabled       = local.is_production
  access_logs_bucket_id     = local.access_logs_bucket_id
  cloudfront_enabled        = true
  cloudfront_arn            = module.cloudfront-distribution-lg.cloudfront_arn
  bucket_name               = var.lloyd_george_bucket_name
  enable_bucket_versioning  = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = local.is_force_destroy
  enable_cors_configuration = true
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["POST", "PUT", "DELETE"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_methods = ["GET"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

module "migration-dynamodb-segment-store" {
  source                    = "./modules/s3/"
  access_logs_enabled       = local.is_production
  access_logs_bucket_id     = local.access_logs_bucket_id
  bucket_name               = var.migration_dynamodb_segment_store_bucket_name
  enable_cors_configuration = false
  enable_bucket_versioning  = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = local.is_force_destroy
}

module "statistical-reports-store" {
  source                    = "./modules/s3/"
  access_logs_enabled       = local.is_production
  access_logs_bucket_id     = local.access_logs_bucket_id
  bucket_name               = var.statistical_reports_bucket_name
  enable_cors_configuration = true
  enable_bucket_versioning  = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = local.is_force_destroy
  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

module "ndr-bulk-staging-store" {
  source                    = "./modules/s3/"
  access_logs_enabled       = local.is_production
  access_logs_bucket_id     = local.access_logs_bucket_id
  bucket_name               = var.staging_store_bucket_name
  enable_cors_configuration = true
  enable_bucket_versioning  = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = local.is_force_destroy
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["POST", "PUT", "DELETE"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_methods = ["GET"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

module "ndr-truststore" {
  count                    = local.is_sandbox ? 0 : 1
  source                   = "./modules/s3"
  access_logs_enabled      = local.is_production
  access_logs_bucket_id    = local.access_logs_bucket_id
  bucket_name              = var.truststore_bucket_name
  environment              = var.environment
  owner                    = var.owner
  enable_bucket_versioning = true
  force_destroy            = local.is_force_destroy
}

data "aws_s3_object" "truststore_ext_cert" {
  bucket = local.truststore_bucket_id
  key    = var.ca_pem_filename
}

module "ndr-document-pending-review-store" {
  source                    = "./modules/s3"
  access_logs_enabled       = local.is_production
  access_logs_bucket_id     = local.access_logs_bucket_id
  bucket_name               = var.document_pending_review_bucket_name
  environment               = var.environment
  owner                     = var.owner
  enable_bucket_versioning  = true
  force_destroy             = local.is_force_destroy
  cloudfront_enabled        = true
  cloudfront_arn            = module.cloudfront-distribution-lg.cloudfront_arn
  enable_cors_configuration = true
  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = [contains(["prod"], terraform.workspace) ? "https://${var.domain}" : "https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

# Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "lg-lifecycle-rules" {
  bucket = module.ndr-lloyd-george-store.bucket_id
  rule {
    id     = "Delete stitched LG records"
    status = "Enabled"

    expiration {
      days = 1
    }

    filter {
      tag {
        key   = "autodelete"
        value = "true"
      }
    }
  }
  rule {
    id     = "default-to-intelligent-tiering"
    status = "Enabled"
    transition {
      storage_class = "INTELLIGENT_TIERING"
      days          = 0
    }
    filter {}
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "doc-store-lifecycle-rules" {
  bucket = module.ndr-document-store.bucket_id
  rule {
    id     = "default-to-intelligent-tiering"
    status = "Enabled"
    transition {
      storage_class = "INTELLIGENT_TIERING"
      days          = 0
    }
    filter {}
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "staging-store-lifecycle-rules" {
  bucket = module.ndr-bulk-staging-store.bucket_id
  rule {
    id     = "Delete objects in user_upload folder that have existed for 24 hours"
    status = "Enabled"

    expiration {
      days = 1
    }

    filter {
      prefix = "user_upload/"
    }
  }
  rule {
    id     = "default-to-intelligent-tiering"
    status = "Enabled"
    transition {
      storage_class = "INTELLIGENT_TIERING"
      days          = 0
    }
    filter {}
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ndr-zip-request-store-lifecycle-rules" {
  bucket = module.ndr-zip-request-store.bucket_id
  rule {
    id     = "Delete objects in the zip request store bucket that have existed for 24 hours"
    status = "Enabled"

    expiration {
      days = 1
    }
    filter {}
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "pdm_document_store" {
  bucket = module.pdm-document-store.bucket_id
  rule {
    id     = "default-to-intelligent-tiering"
    status = "Enabled"
    transition {
      storage_class = "INTELLIGENT_TIERING"
      days          = 0
    }
    filter {}
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "ndr_document_pending_review_store" {
  bucket = module.ndr-document-pending-review-store.bucket_id
  rule {
    id     = "default-to-intelligent-tiering"
    status = "Enabled"
    transition {
      storage_class = "INTELLIGENT_TIERING"
      days          = 0
    }
    filter {}
  }
}


# Logging Buckets
resource "aws_s3_bucket" "access_logs" {
  count         = local.access_logs_count
  bucket        = "${terraform.workspace}-ndr-access-logs"
  force_destroy = local.is_force_destroy

  tags = {
    Name        = "${terraform.workspace}-ndr-access-logs"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

data "aws_iam_policy_document" "access_logs" {
  count = local.access_logs_count
  statement {
    sid     = "AllowS3AccessLogsPolicy"
    effect  = "Allow"
    actions = ["s3:PutObject"]
    resources = [
      "${aws_s3_bucket.access_logs[0].arn}/*",
    ]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
  }
  statement {
    sid    = "DenyS3AccessLogsPolicy"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.access_logs[0].arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  count  = local.access_logs_count
  bucket = aws_s3_bucket.access_logs[0].id
  policy = data.aws_iam_policy_document.access_logs[0].json
}

resource "aws_s3_bucket_versioning" "access_logs" {
  count  = local.access_logs_count
  bucket = aws_s3_bucket.access_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket        = "${terraform.workspace}-load-balancer-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = local.is_force_destroy

  tags = {
    Name        = "${terraform.workspace}-load-balancer-logs-${data.aws_caller_identity.current.account_id}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_s3_bucket_versioning" "logs_bucket" {
  count = local.is_production ? 1 : 0

  bucket = aws_s3_bucket.logs_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "logs_bucket" {
  bucket = aws_s3_bucket.logs_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "logs_bucket_policy" {
  statement {
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.logs_bucket.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.logs_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "logs_bucket_policy" {
  bucket = aws_s3_bucket.logs_bucket.id
  policy = data.aws_iam_policy_document.logs_bucket_policy.json
}

resource "aws_s3_bucket_logging" "logs_bucket_logging" {
  count         = local.access_logs_count
  bucket        = aws_s3_bucket.logs_bucket.id
  target_bucket = local.access_logs_bucket_id
  target_prefix = "${aws_s3_bucket.logs_bucket.id}/"
}

module "pdm-document-store" {
  source                   = "./modules/s3/"
  access_logs_enabled      = local.is_production
  access_logs_bucket_id    = local.access_logs_bucket_id
  bucket_name              = var.pdm_document_bucket_name
  enable_bucket_versioning = true
  environment              = var.environment
  owner                    = var.owner
  force_destroy            = local.is_force_destroy
}
