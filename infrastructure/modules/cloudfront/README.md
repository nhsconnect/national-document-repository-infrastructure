## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.nocache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.cloudfront_s3_oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_request_policy.viewer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_domain_name"></a> [bucket\_domain\_name](#input\_bucket\_domain\_name) | Domain name to assign CloudFront distribution to | `string` | n/a | yes |
| <a name="input_bucket_id"></a> [bucket\_id](#input\_bucket\_id) | Bucket ID to assign CloudFront distribution to | `string` | n/a | yes |
| <a name="input_qualifed_arn"></a> [qualifed\_arn](#input\_qualifed\_arn) | Lambda@Edge function association | `string` | n/a | yes |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | Web ACL to associate this Cloudfront distribution with | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_arn"></a> [cloudfront\_arn](#output\_cloudfront\_arn) | The ARN of the CloudFront Distribution |
| <a name="output_cloudfront_url"></a> [cloudfront\_url](#output\_cloudfront\_url) | n/a |
