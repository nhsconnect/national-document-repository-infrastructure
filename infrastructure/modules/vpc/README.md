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

<!-- END_TF_DOCS -->
