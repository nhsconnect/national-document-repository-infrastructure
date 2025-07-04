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
| [aws_route53_record.ndr_fargate_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.ndr_gateway_api_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.ndr_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.ndr_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_gateway_full_domain_name"></a> [api\_gateway\_full\_domain\_name](#input\_api\_gateway\_full\_domain\_name) | Full domain name for api gateway custom domain. Example: api-dev.access-request-fulfilment.patient-deductions.nhs.uk | `string` | n/a | yes |
| <a name="input_api_gateway_subdomain_name"></a> [api\_gateway\_subdomain\_name](#input\_api\_gateway\_subdomain\_name) | Subdomain name for api gateway custom domain. Example: api-dev | `string` | n/a | yes |
| <a name="input_api_gateway_zone_id"></a> [api\_gateway\_zone\_id](#input\_api\_gateway\_zone\_id) | Zone Id for api gateway custom domain | `string` | n/a | yes |
| <a name="input_certificate_domain"></a> [certificate\_domain](#input\_certificate\_domain) | n/a | `string` | n/a | yes |
| <a name="input_dns_name"></a> [dns\_name](#input\_dns\_name) | n/a | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_domain) | n/a | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
| <a name="input_using_arf_hosted_zone"></a> [using\_arf\_hosted\_zone](#input\_using\_arf\_hosted\_zone) | n/a | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_zone_id"></a> [zone\_id](#output\_zone\_id) | n/a |
