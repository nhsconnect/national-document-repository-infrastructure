# WAFv2 Web ACL Module

## Features

- WAFv2 Web ACL provisioning
- Regex pattern sets for:
  - XSS in body
  - Large request bodies
  - CMS-related URIs
- CloudFront-compatible WAF scope toggle
- Named and tagged by environment and owner

---

## Usage

```hcl
module "waf_acl" {
  source = "./modules/waf-acl"

  # Required: true if the ACL is being used for CloudFront (sets scope to CLOUDFRONT)
  cloudfront_acl = true

  # Required: used to tag and namespace the ACL and regex pattern sets
  environment = "prod"

  # Required: resource owner for tagging
  owner = "security-team"
}


```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Usage
Basic usage of this module is as follows:

```hcl
module "example" {
  	source = "<module-path>"
  
	# Required variables
  	cloudfront_acl = 
  	environment = 
  	owner = 
}
```

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_regex_pattern_set.exclude_cms_uri](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set) | resource |
| [aws_wafv2_regex_pattern_set.large_body_uri](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set) | resource |
| [aws_wafv2_regex_pattern_set.xss_body_uri](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set) | resource |
| [aws_wafv2_web_acl.waf_v2_acl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudfront_acl"></a> [cloudfront\_acl](#input\_cloudfront\_acl) | n/a | `bool` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The arn of the web acl. |
<!-- END_TF_DOCS -->
