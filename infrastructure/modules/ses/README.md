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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_route53_record.ndr_ses_dkim_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ses_domain_dkim.ndr_dkim](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_dkim) | resource |
| [aws_ses_domain_identity.ndr_ses](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity) | resource |
| [aws_ses_domain_identity_verification.ndr_ses_domain_verification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ses_domain_identity_verification) | resource |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | n/a | yes |
| <a name="input_domain_prefix"></a> [domain\_prefix](#input\_domain\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_enable"></a> [enable](#input\_enable) | n/a | `bool` | n/a | yes |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | n/a | `string` | n/a | yes |
## Outputs

No outputs.
<!-- END_TF_DOCS -->
