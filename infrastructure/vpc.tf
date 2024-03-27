# Create VPC Region

module "ndr-vpc-ui" {
  source = "./modules/vpc/"

  # Variables
  standalone_vpc_tag          = var.standalone_vpc_tag
  availability_zones          = var.availability_zones
  enable_private_routes       = true
  enable_dns_support          = var.enable_dns_support
  enable_dns_hostnames        = var.enable_dns_hostnames
  num_public_subnets          = var.num_public_subnets
  num_private_subnets         = var.num_private_subnets
  endpoint_interface_services = ["ecr.api", "logs", "secretsmanager", "ecr.dkr", "ssm"]
  endpoint_gateway_services   = ["s3", "dynamodb"]
  security_group_id           = module.ndr-ecs-fargate.security_group_id

  # Tags
  environment = var.environment
  owner       = var.owner
}
