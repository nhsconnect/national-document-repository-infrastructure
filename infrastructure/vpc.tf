# Create VPC Region

module "ndr-vpc-ui" {
  source = "./modules/vpc/"

  # Variables
  standalone_vpc_tag          = var.standalone_vpc_tag
  standalone_vpc_ig_tag       = var.standalone_vpc_ig_tag
  availability_zones          = var.availability_zones
  enable_private_routes       = true
  enable_dns_support          = var.enable_dns_support
  enable_dns_hostnames        = var.enable_dns_hostnames
  num_public_subnets          = var.num_public_subnets
  num_private_subnets         = var.num_private_subnets
  endpoint_interface_services = ["ecr.api", "logs", "secretsmanager", "ecr.dkr", "ssm"]
  endpoint_gateway_services   = ["s3", "dynamodb"]
  security_group_id           = module.ndr-ecs-fargate-app.security_group_id
  is_sandbox                  = local.is_sandbox

  # Tags
  environment = var.environment
  owner       = var.owner
}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id  = aws_default_vpc.default.id
  ingress = []
  egress  = []
}