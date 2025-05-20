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

| Name                                                                                                                                    | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_route53_record.ndr_fargate_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)     | resource    |
| [aws_route53_record.ndr_gateway_api_record](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource    |
| [aws_route53_zone.ndr_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone)                   | resource    |
| [aws_route53_zone.ndr_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)                | data source |

## Inputs

| Name                                                                                                                  | Description                                                                                                          | Type     | Default | Required |
| --------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------- | -------- | ------- | :------: |
| <a name="input_api_gateway_full_domain_name"></a> [api_gateway_full_domain_name](#input_api_gateway_full_domain_name) | Full domain name for api gateway custom domain. Example: api-dev.access-request-fulfilment.patient-deductions.nhs.uk | `string` | n/a     |   yes    |
| <a name="input_api_gateway_subdomain_name"></a> [api_gateway_subdomain_name](#input_api_gateway_subdomain_name)       | Subdomain name for api gateway custom domain. Example: api-dev                                                       | `string` | n/a     |   yes    |
| <a name="input_api_gateway_zone_id"></a> [api_gateway_zone_id](#input_api_gateway_zone_id)                            | Zone Id for api gateway custom domain                                                                                | `string` | n/a     |   yes    |
| <a name="input_certificate_domain"></a> [certificate_domain](#input_certificate_domain)                               | n/a                                                                                                                  | `string` | n/a     |   yes    |
| <a name="input_dns_name"></a> [dns_name](#input_dns_name)                                                             | n/a                                                                                                                  | `string` | n/a     |   yes    |
| <a name="input_domain"></a> [domain](#input_domain)                                                                   | n/a                                                                                                                  | `string` | n/a     |   yes    |
| <a name="input_environment"></a> [environment](#input_environment)                                                    | n/a                                                                                                                  | `string` | n/a     |   yes    |
| <a name="input_owner"></a> [owner](#input_owner)                                                                      | n/a                                                                                                                  | `string` | n/a     |   yes    |
| <a name="input_using_arf_hosted_zone"></a> [using_arf_hosted_zone](#input_using_arf_hosted_zone)                      | n/a                                                                                                                  | `bool`   | `true`  |    no    |

## Outputs

| Name                                                     | Description |
| -------------------------------------------------------- | ----------- |
| <a name="output_zone_id"></a> [zone_id](#output_zone_id) | n/a         |

<!-- END_TF_DOCS -->
