# Document Store Bucket
module "ndr-document-store" {
  source                    = "./modules/s3/"
  bucket_name               = var.docstore_bucket_name
  enable_cors_configuration = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = contains(["ndra", "ndrb", "ndr-test"], terraform.workspace)
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["POST", "DELETE"]
      allowed_origins = ["https://${terraform.workspace}.${var.domain}"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_methods = ["GET"]
      allowed_origins = ["https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

# Zip Request Store Bucket
module "ndr-zip-request-store" {
  source                    = "./modules/s3/"
  bucket_name               = var.zip_store_bucket_name
  enable_cors_configuration = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = contains(["ndra", "ndrb", "ndr-test"], terraform.workspace)
  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

# Lloyd George Store Bucket
module "ndr-lloyd-george-store" {
  source                    = "./modules/s3/"
  bucket_name               = var.lloyd_george_bucket_name
  enable_cors_configuration = true
  environment               = var.environment
  owner                     = var.owner
  force_destroy             = contains(["ndra", "ndrb", "ndr-test"], terraform.workspace)
  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["POST", "DELETE"]
      allowed_origins = ["https://${terraform.workspace}.${var.domain}"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      allowed_methods = ["GET"]
      allowed_origins = ["https://${terraform.workspace}.${var.domain}"]
    }
  ]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.ndr-document-store.s3_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.fake_virus_scanned_event_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.s3_permission_for_fake_virus_scanned_event]
}

#resource "aws_lambda_permission" "s3_permission_for_fake_virus_scanned_event" {
#  statement_id  = "AllowFakeScanExecutionFromS3Bucket"
#  action        = "lambda:InvokeFunction"
#  function_name = aws_lambda_function.fake_virus_scanned_event_lambda.arn
#  principal     = "s3.amazonaws.com"
#  source_arn    = module.ndr-document-store.s3_bucket_arn
#}