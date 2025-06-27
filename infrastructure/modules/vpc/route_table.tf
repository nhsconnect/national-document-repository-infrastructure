resource "aws_route_table" "public" {
  count  = var.is_sandbox ? 0 : var.num_public_subnets > 0 ? 1 : 0
  vpc_id = local.is_production ? aws_vpc.vpc[0].id : data.aws_vpc.vpc[0].id
  tags = {
    Name        = "${terraform.workspace}-public-route-table"
    Zone        = "Public"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace

  }
}

resource "aws_route_table" "private" {
  count  = var.is_sandbox ? 0 : var.num_public_subnets > 0 ? 1 : 0
  vpc_id = local.is_production ? aws_vpc.vpc[0].id : data.aws_vpc.vpc[0].id
  tags = {
    Name        = "${terraform.workspace}-private-route-table"
    Zone        = "Private"
    Owner       = var.owner
    Environment = var.environment
    Workspace   = terraform.workspace

  }
}

resource "aws_route" "public" {
  count                  = var.is_sandbox ? 0 : var.num_public_subnets > 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = var.ig_cidr
  gateway_id             = local.is_production ? aws_internet_gateway.ig[0].id : data.aws_internet_gateway.ig[0].id
}

resource "aws_route" "private" {
  count                       = var.is_sandbox ? 0 : (var.num_private_subnets > 0) && var.enable_private_routes ? 1 : 0
  route_table_id              = aws_route_table.private[0].id
  destination_ipv6_cidr_block = var.ig_ipv6_cidr
  gateway_id                  = local.is_production ? aws_internet_gateway.ig[0].id : data.aws_internet_gateway.ig[0].id
}

resource "aws_route_table_association" "public" {
  count          = var.is_sandbox ? 0 : var.num_public_subnets
  subnet_id      = var.is_sandbox ? element(data.aws_subnet.public_subnets[*].id, count.index) : element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  count          = var.is_sandbox ? 0 : var.enable_private_routes ? var.num_private_subnets : 0
  subnet_id      = var.is_sandbox ? element(data.aws_subnet.private_subnets[*].id, count.index) : element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = aws_route_table.private[0].id
}

resource "aws_nat_gateway" "public" {
  count             = var.is_sandbox ? 0 : 1
  allocation_id     = aws_eip.eip[0].id
  subnet_id         = aws_subnet.public_subnets[1].id
  connectivity_type = "public"
  tags = {
    Name = "gw NAT"
  }
  depends_on = [aws_internet_gateway.ig, aws_subnet.public_subnets[1]]
}

resource "aws_eip" "eip" {
  count  = var.is_sandbox ? 0 : 1
  domain = "vpc"
}

resource "aws_route" "nat_route" {
  count                  = var.is_sandbox ? 0 : 1
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public[0].id
  depends_on             = [aws_route_table.private[0]]
}