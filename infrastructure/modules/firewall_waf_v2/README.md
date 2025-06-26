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

<!-- END_TF_DOCS -->
