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
