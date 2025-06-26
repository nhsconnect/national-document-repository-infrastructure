# SES Domain Identity & DKIM Module

## Features

- SES domain identity registration
- SES domain verification trigger
- DKIM setup for secure email validation
- Route53 DNS records for DKIM CNAMEs
- Toggle-based resource creation

---

## Usage

```hcl
module "ses_identity" {
  source = "./modules/ses"

  # Required: Root domain (e.g. example.com)
  domain = "example.com"

  # Required: Subdomain or prefix used to create identity.
  domain_prefix = "email"

  # Required: ID of the hosted zone where DNS records will be created
  zone_id = "Z0123456789ABCDEFG"

  # Required: Whether to enable creation of SES identity
  enable = true
}

```

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->
