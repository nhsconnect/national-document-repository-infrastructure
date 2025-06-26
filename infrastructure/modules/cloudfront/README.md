# CloudFront Distribution Module

## Features

- CloudFront distribution targeting S3 origin
- Origin Access Control (OAC) for secure S3 access
- Custom cache and origin request policies
- Optional Lambda@Edge function integration
- Optional WAF Web ACL association
- Outputs distribution ARN and access URL

---

## Usage

```hcl
module "cloudfront" {
  source = "./modules/cloudfront"

  # Required
  bucket_id          = "my-s3-bucket"
  bucket_domain_name = "my-s3-bucket.s3.amazonaws.com"

  # Optional: Lambda@Edge function ARN.
  qualifed_arn = "arn:aws:lambda:us-east-1:123456789:function:myFn:1"

  # Optional: AWS WAF Web ACL ARN
  web_acl_id = "arn:aws:wafv2:us-east-1:123456789:regional/webacl/my-acl/abc123"
}

```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
