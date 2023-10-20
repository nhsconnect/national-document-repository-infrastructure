resource "aws_s3_bucket" "bucket" {
  bucket        = "${terraform.workspace}-${var.bucket_name}"
  force_destroy = var.force_destroy

  tags = {
    Name        = "${terraform.workspace}-${var.bucket_name}"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Principal" : {
          "AWS" : "*"
        },
        "Action" : [
          "s3:*"
        ],
        "Resource" : [
          "${aws_s3_bucket.bucket.arn}/*",
          "${aws_s3_bucket.bucket.arn}"
        ],
        "Effect" : "Deny",
        "Condition" : {
          "Bool" : {
            "aws:SecureTransport" : "false"
          }
        }
      }
    ]
  })
  depends_on = [aws_s3_bucket.bucket]
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket     = aws_s3_bucket.bucket.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
  depends_on = [aws_s3_bucket.bucket, aws_s3_bucket_policy.bucket_policy]
}

resource "aws_s3_bucket_cors_configuration" "document_store_bucket_cors_config" {
  bucket = aws_s3_bucket.bucket.id
  count  = var.enable_cors_configuration ? 1 : 0
  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
  depends_on = [aws_s3_bucket.bucket, aws_s3_bucket_acl.bucket_acl]
}
