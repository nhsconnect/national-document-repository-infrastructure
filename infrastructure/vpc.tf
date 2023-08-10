# Create VPC Region

module "ndr-vpc-ui" {
  source = "./modules/vpc/"

  # Variables
  availability_zones    = var.availability_zones
  enable_private_routes = var.enable_private_routes
  enable_dns_support    = var.enable_dns_support
  enable_dns_hostnames  = var.enable_dns_hostnames
  num_public_subnets    = var.num_public_subnets
  num_private_subnets   = var.num_private_subnets

  # Tags
  environment = var.environment
  owner       = var.owner
}