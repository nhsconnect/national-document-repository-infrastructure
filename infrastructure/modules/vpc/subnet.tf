resource "aws_subnet" "public_subnets" {
  count             = var.is_sandbox ? 0 : var.num_public_subnets
  vpc_id            = local.is_production ? aws_vpc.vpc[0].id : data.aws_vpc.vpc[0].id
  cidr_block        = local.is_production ? element(local.public_subnet_cidrs_prod, count.index) : element(local.public_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name        = "${terraform.workspace}-public-subnet-${count.index + 1}"
    Zone        = "Public"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.is_sandbox ? 0 : var.num_private_subnets
  vpc_id            = local.is_production ? aws_vpc.vpc[0].id : data.aws_vpc.vpc[0].id
  cidr_block        = local.is_production ? element(local.private_subnet_cidrs_prod, count.index) : element(local.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name        = "${terraform.workspace}-private-subnet-${count.index + 1}"
    Zone        = "Private"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}

data "aws_subnet" "public_subnets" {
  count = var.is_sandbox ? var.num_public_subnets : 0
  tags = {
    Name = "${var.standalone_vpc_tag}-public-subnet-${count.index + 1}"
  }
}

data "aws_subnet" "private_subnets" {
  count = var.is_sandbox ? var.num_public_subnets : 0
  tags = {
    Name = "${var.standalone_vpc_tag}-private-subnet-${count.index + 1}"
  }
}
