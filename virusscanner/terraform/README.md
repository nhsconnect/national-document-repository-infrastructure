## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudformation_stack.s3_virus_scanning_stack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_route_table.virus_scanning_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.virus_scanning_subnet1_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.virus_scanning_subnet2_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_sns_topic_subscription.proactive_notifications_sns_topic_subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_ssm_parameter.virus_scan_notifications_sns_topic_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_subnet.virus_scanning_subnet1](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.virus_scanning_subnet2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_cloudformation_export.proactive_notifications_sns_topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudformation_export) | data source |
| [aws_internet_gateway.ig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway) | data source |
| [aws_ssm_parameter.cloud_security_admin_email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.cloud_security_notification_email_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.virus_scanning_subnet_cidr_range](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_black_hole_address"></a> [black\_hole\_address](#input\_black\_hole\_address) | using reserved address that does not lead anywhere to make sure CloudStorageSecurity console is not available | `string` | `"198.51.100.0/24"` | no |
| <a name="input_cloud_security_email_param_environment"></a> [cloud\_security\_email\_param\_environment](#input\_cloud\_security\_email\_param\_environment) | This is the environement reference in cloud security email param store key | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | n/a | `string` | n/a | yes |
| <a name="input_public_address"></a> [public\_address](#input\_public\_address) | using public address to make sure CloudStorageSecurity console is available | `string` | `"0.0.0.0/0"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"eu-west-2"` | no |
| <a name="input_standalone_vpc_ig_tag"></a> [standalone\_vpc\_ig\_tag](#input\_standalone\_vpc\_ig\_tag) | This is the tag assigned to the standalone vpc ig that should be created as part of the main infrastructure or manually as part of a swap startergy before the first run of the infrastructure | `string` | n/a | yes |
| <a name="input_standalone_vpc_tag"></a> [standalone\_vpc\_tag](#input\_standalone\_vpc\_tag) | This is the tag assigned to the standalone vpc that should be created manaully before the first run of the infrastructure | `string` | n/a | yes |

## Outputs

No outputs.
