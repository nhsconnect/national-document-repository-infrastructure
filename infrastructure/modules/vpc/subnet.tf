resource "aws_subnet" "public_subnets" {
  count             = var.num_public_subnets
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = element(local.public_subnet_cidrs, count.index)
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
  count             = var.num_private_subnets
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = element(local.private_subnet_cidrs, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    Name        = "${terraform.workspace}-private-subnet-${count.index + 1}"
    Zone        = "Private"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace
  }
}
