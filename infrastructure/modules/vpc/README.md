````

# VPC Networking Module with Subnets, Routing, and VPC Endpoints

This Terraform module provisions a VPC with public and private subnets, internet/NAT gateways, route tables, and optional VPC interface and gateway endpoints. It is designed for reusable infrastructure in staging or production environments with support for shared or standalone deployments.

---

## Features

- VPC creation with custom CIDR block
- Public and private subnet creation across multiple AZs
- Internet Gateway (IGW) setup
- Public and private route tables with associations
- Optional VPC interface and gateway endpoints (e.g., S3, CloudWatch)
- Tags applied by environment and owner

---

## Usage

```hcl
module "vpc" {
  source = "./modules/network"

  # Required: Custom tags
  environment = "prod"
  owner       = "platform"

  # Required: Number of public and private subnets to create
  num_public_subnets  = 2
  num_private_subnets = 2

  # Required: AZs to spread subnets across
  availability_zones = ["eu-west-2a", "eu-west-2b"]

  # Required: Services for VPC endpoints (interface and gateway)
  endpoint_interface_services = ["ecr.api", "logs"]
  endpoint_gateway_services   = ["s3"]

  # Required: Security group to associate with VPC endpoints
  security_group_id = aws_security_group.vpc_default.id

  # Required: Tags to find existing standalone VPC and IGW (when applicable)
  standalone_vpc_tag     = "shared-vpc"
  standalone_vpc_ig_tag  = "shared-igw"

  # Optional: VPC CIDR block
  vpc_cidr = "10.1.0.0/16"

  # Optional: Route control
  enable_private_routes = true

  # Optional: DNS settings
  enable_dns_support   = true
  enable_dns_hostnames = true
}


````

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
## Resources

| Name | Type |
|------|------|
| [aws_default_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.ig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.nat_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.ndr_gateway_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ndr_interface_vpc_endpoint](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_internet_gateway.ig](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/internet_gateway) | data source |
| [aws_subnet.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_subnet.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | This list specifies all the Availability Zones that will have a pair of public and private subnets. | `list(string)` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | This allows AWS DNS hostname support to be switched on or off. | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | This allows AWS DNS support to be switched on or off. | `bool` | `true` | no |
| <a name="input_enable_private_routes"></a> [enable\_private\_routes](#input\_enable\_private\_routes) | Whether to enable NAT routing for private subnets. | `bool` | `false` | no |
| <a name="input_endpoint_gateway_services"></a> [endpoint\_gateway\_services](#input\_endpoint\_gateway\_services) | List of AWS services to enable as VPC gateway endpoints. | `list(string)` | n/a | yes |
| <a name="input_endpoint_interface_services"></a> [endpoint\_interface\_services](#input\_endpoint\_interface\_services) | List of AWS services to enable as VPC interface endpoints. | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment tag used to classify resources (e.g., dev, staging, prod). | `string` | n/a | yes |
| <a name="input_ig_cidr"></a> [ig\_cidr](#input\_ig\_cidr) | This specifies the CIDR block for the internet gateway. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_ig_ipv6_cidr"></a> [ig\_ipv6\_cidr](#input\_ig\_ipv6\_cidr) | This specifies the IPV6 CIDR block for the internet gateway. | `string` | `"::/0"` | no |
| <a name="input_num_private_subnets"></a> [num\_private\_subnets](#input\_num\_private\_subnets) | The number of private subnets to create across availability zones. | `number` | n/a | yes |
| <a name="input_num_public_subnets"></a> [num\_public\_subnets](#input\_num\_public\_subnets) | The number of public subnets to create across availability zones. | `number` | n/a | yes |
| <a name="input_owner"></a> [owner](#input\_owner) | The owner tag used to identify responsible team or individual. | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | The security group ID to associate with VPC endpoints. | `any` | n/a | yes |
| <a name="input_standalone_vpc_ig_tag"></a> [standalone\_vpc\_ig\_tag](#input\_standalone\_vpc\_ig\_tag) | This is the tag assigned to the standalone VPC internet gateway that should be created manually before the first run of the infrastructure. | `string` | n/a | yes |
| <a name="input_standalone_vpc_tag"></a> [standalone\_vpc\_tag](#input\_standalone\_vpc\_tag) | This is the tag assigned to the standalone VPC that should be created manaully before the first run of the infrastructure. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | This specifices the VPC CIDR block | `string` | `"10.0.0.0/16"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | n/a |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | n/a |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | n/a |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | n/a |
<!-- END_TF_DOCS -->
