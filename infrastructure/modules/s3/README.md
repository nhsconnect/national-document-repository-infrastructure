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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.s3_backup_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_document_data_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.s3_list_object_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_s3_bucket.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.bucket_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_cors_configuration.document_store_bucket_cors_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_cors_configuration) | resource |
| [aws_s3_bucket_logging.bucket_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.s3_cloudfront_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_default_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_read_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.s3_write_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket_id"></a> [access\_logs\_bucket\_id](#input\_access\_logs\_bucket\_id) | Enables access logs on the module's bucket | `string` | n/a | yes |
| <a name="input_access_logs_enabled"></a> [access\_logs\_enabled](#input\_access\_logs\_enabled) | Whether to enable S3 access logging for this bucket. | `bool` | `false` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | The name of the S3 bucket to create. | `string` | n/a | yes |
| <a name="input_cloudfront_arn"></a> [cloudfront\_arn](#input\_cloudfront\_arn) | CloudFront distribution ARN association and policy toggles | `string` | `"null"` | no |
| <a name="input_cloudfront_enabled"></a> [cloudfront\_enabled](#input\_cloudfront\_enabled) | Enables the correct policy config for CloudFront associated S3 bucket | `bool` | `false` | no |
| <a name="input_cors_rules"></a> [cors\_rules](#input\_cors\_rules) | List of CORS rules to apply to the S3 bucket. | `list` | `[]` | no |
| <a name="input_enable_bucket_versioning"></a> [enable\_bucket\_versioning](#input\_enable\_bucket\_versioning) | Whether to enable versioning on the bucket. | `bool` | `false` | no |
| <a name="input_enable_cors_configuration"></a> [enable\_cors\_configuration](#input\_enable\_cors\_configuration) | Whether to enable CORS configuration for the S3 bucket. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment label used for tagging (e.g., 'dev', 'prod'). | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional, Default:false ) A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner label used for resource tagging. | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | n/a |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | n/a |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | n/a |
| <a name="output_s3_list_object_policy"></a> [s3\_list\_object\_policy](#output\_s3\_list\_object\_policy) | n/a |
| <a name="output_s3_object_access_policy"></a> [s3\_object\_access\_policy](#output\_s3\_object\_access\_policy) | n/a |
| <a name="output_s3_read_policy_document"></a> [s3\_read\_policy\_document](#output\_s3\_read\_policy\_document) | n/a |
| <a name="output_s3_write_policy_document"></a> [s3\_write\_policy\_document](#output\_s3\_write\_policy\_document) | n/a |
<!-- END_TF_DOCS -->
