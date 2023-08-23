resource "aws_route_table" "public" {
  count  = var.num_public_subnets > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${terraform.workspace}-public-route-table"
    Zone        = "Public"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace

  }
}

resource "aws_route_table" "private" {
  count  = var.num_private_subnets > 0 ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${terraform.workspace}-private-route-table"
    Zone        = "Private"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace

  }
}

resource "aws_route" "public" {
  count                  = var.num_public_subnets > 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = var.ig_cidr
  gateway_id             = aws_internet_gateway.ig[0].id
}

resource "aws_route" "private" {
  count                       = (var.num_private_subnets > 0) && var.enable_private_routes ? 1 : 0
  route_table_id              = aws_route_table.private[0].id
  destination_ipv6_cidr_block = var.ig_ipv6_cidr
  gateway_id                  = aws_internet_gateway.ig[0].id
}

resource "aws_route_table_association" "public" {
  count          = var.num_public_subnets
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count          = var.enable_private_routes ? var.num_private_subnets : 0
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private[0].id
}