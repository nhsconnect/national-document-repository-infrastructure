# S3 Bucket Module with Access Control and Optional CloudFront Support

## Features

- S3 bucket with:
  - Optional versioning
  - Force destroy toggle
  - Configurable CORS rules
- Optional access logging to a separate bucket
- Optional CloudFront-specific policy support
- IAM policies for read, write, list, and backup access
- Full tagging via environment and owner variables

---

## Usage

```hcl
module "s3_bucket" {
  source = "./modules/s3"

  # Required: Logical name for the bucket
  bucket_name = "my-app-assets"

  # Required: Tags for identification
  environment = "prod"
  owner       = "platform"

  # Optional: Enable versioning to preserve object history
  enable_bucket_versioning = true

  # Optional: Force destroy (delete even if non-empty)
  force_destroy = true

  # Optional: Enable access logs and specify destination bucket ID
  access_logs_enabled   = true
  access_logs_bucket_id = "log-bucket-123"

  # Optional: CORS configuration (if hosting front-end apps)
  enable_cors_configuration = true
  cors_rules = [
    {
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      allowed_headers = ["*"]
    }
  ]

  # Optional: Enable CloudFront integration and policy
  cloudfront_enabled = true
  cloudfront_arn     = "arn:aws:cloudfront::123456789012:distribution/ABC123"
}


```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
