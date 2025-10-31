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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.nocache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_distribution.distribution_with_secondary_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.cloudfront_s3_oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_request_policy.viewer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_domain_name"></a> [bucket\_domain\_name](#input\_bucket\_domain\_name) | Domain name to assign CloudFront distribution to. | `string` | n/a | yes |
| <a name="input_bucket_id"></a> [bucket\_id](#input\_bucket\_id) | Bucket ID to assign CloudFront distribution to. | `string` | n/a | yes |
| <a name="input_has_secondary_bucket"></a> [has\_secondary\_bucket](#input\_has\_secondary\_bucket) | Whether distribution is associated with a secondary bucket | `bool` | n/a | yes |
| <a name="input_log_bucket_id"></a> [log\_bucket\_id](#input\_log\_bucket\_id) | The bucket ID to send access logs to | `string` | n/a | yes |
| <a name="input_qualifed_arn"></a> [qualifed\_arn](#input\_qualifed\_arn) | Lambda@Edge function association. | `string` | n/a | yes |
| <a name="input_secondary_bucket_domain_name"></a> [secondary\_bucket\_domain\_name](#input\_secondary\_bucket\_domain\_name) | Secondary bucket domain name | `string` | n/a | yes |
| <a name="input_secondary_bucket_id"></a> [secondary\_bucket\_id](#input\_secondary\_bucket\_id) | Secondary bucket ID | `string` | n/a | yes |
| <a name="input_secondary_bucket_path_pattern"></a> [secondary\_bucket\_path\_pattern](#input\_secondary\_bucket\_path\_pattern) | Path pattern for secondary bucket | `string` | n/a | yes |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | Web ACL to associate this CloudFront distribution with. | `string` | `""` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_arn"></a> [cloudfront\_arn](#output\_cloudfront\_arn) | The ARN of the CloudFront Distribution |
| <a name="output_cloudfront_url"></a> [cloudfront\_url](#output\_cloudfront\_url) | n/a |
<!-- END_TF_DOCS -->
