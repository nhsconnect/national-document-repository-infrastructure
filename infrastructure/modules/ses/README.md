# SES Domain Identity & DKIM Module

This Terraform module provisions an Amazon SES domain identity and sets up DKIM (DomainKeys Identified Mail) authentication using Route53 DNS records. It also verifies the domain identity to allow sending emails through SES with trusted deliverability.

This setup is ideal for applications sending transactional or bulk email from verified domains.

---

## Features

- [x] SES domain identity registration
- [x] SES domain verification trigger
- [x] DKIM setup for secure email validation
- [x] Route53 DNS records for DKIM CNAMEs
- [x] Toggle-based resource creation (useful for shared or multitenant zones)

---

## Usage

```hcl
module "ses_identity" {
  source = "./modules/ses"

  # Required: Root domain (e.g. example.com)
  domain = "example.com"

  # Required: Subdomain or prefix used to create identity (e.g. email, support)
  domain_prefix = "email"

  # Required: ID of the hosted zone where DNS records will be created
  zone_id = "Z0123456789ABCDEFG"

  # Required: Whether to enable creation of SES identity and DKIM records
  enable = true
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

| Name                                                                                                                                                                             | Type     |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [aws_route53_record.ndr_ses_dkim_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                             | resource |
| [aws_ses_domain_dkim.ndr_dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim)                                                      | resource |
| [aws_ses_domain_identity.ndr_ses](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity)                                               | resource |
| [aws_ses_domain_identity_verification.ndr_ses_domain_verification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity_verification) | resource |

## Inputs

| Name                                                                     | Description | Type     | Default | Required |
| ------------------------------------------------------------------------ | ----------- | -------- | ------- | :------: |
| <a name="input_domain"></a> [domain](#input_domain)                      | n/a         | `string` | n/a     |   yes    |
| <a name="input_domain_prefix"></a> [domain_prefix](#input_domain_prefix) | n/a         | `string` | n/a     |   yes    |
| <a name="input_enable"></a> [enable](#input_enable)                      | n/a         | `bool`   | n/a     |   yes    |
| <a name="input_zone_id"></a> [zone_id](#input_zone_id)                   | n/a         | `string` | n/a     |   yes    |

## Outputs

No outputs.

<!-- END_TF_DOCS -->
