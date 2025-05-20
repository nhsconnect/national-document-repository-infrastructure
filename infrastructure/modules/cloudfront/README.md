# CloudFront Distribution Module

This Terraform module creates an AWS CloudFront distribution with:

- Custom cache and origin request policies
- Support for Lambda@Edge function associations
- Integration with S3 buckets
- Optional WAF (Web ACL) association

This setup is designed to serve static content efficiently and securely from S3 via CloudFront, with flexibility to include Lambda@Edge logic and WAF security rules.

## Usage

```hcl
module "cloudfront" {
  source             = "./modules/cloudfront"
  bucket_id          = "my-s3-bucket"
  bucket_domain_name = "my-s3-bucket.s3.amazonaws.com"
  qualifed_arn       = "arn:aws:lambda:us-east-1:123456789:function:myFn:1"
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                   | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_cloudfront_cache_policy.nocache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy)                             | resource |
| [aws_cloudfront_distribution.distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)                        | resource |
| [aws_cloudfront_origin_access_control.cloudfront_s3_oac](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_request_policy.viewer_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy)     | resource |

## Inputs

| Name                                                                                    | Description                                            | Type     | Default | Required |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------ | -------- | ------- | :------: |
| <a name="input_bucket_domain_name"></a> [bucket_domain_name](#input_bucket_domain_name) | Domain name to assign CloudFront distribution to       | `string` | n/a     |   yes    |
| <a name="input_bucket_id"></a> [bucket_id](#input_bucket_id)                            | Bucket ID to assign CloudFront distribution to         | `string` | n/a     |   yes    |
| <a name="input_qualifed_arn"></a> [qualifed_arn](#input_qualifed_arn)                   | Lambda@Edge function association                       | `string` | n/a     |   yes    |
| <a name="input_web_acl_id"></a> [web_acl_id](#input_web_acl_id)                         | Web ACL to associate this Cloudfront distribution with | `string` | `""`    |    no    |

## Outputs

| Name                                                                          | Description                            |
| ----------------------------------------------------------------------------- | -------------------------------------- |
| <a name="output_cloudfront_arn"></a> [cloudfront_arn](#output_cloudfront_arn) | The ARN of the CloudFront Distribution |
| <a name="output_cloudfront_url"></a> [cloudfront_url](#output_cloudfront_url) | n/a                                    |

<!-- END_TF_DOCS -->
