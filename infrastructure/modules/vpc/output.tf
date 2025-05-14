output "vpc_id" {
  value = local.is_production ? aws_vpc.vpc[0].id : data.aws_vpc.vpc[0].id
}

output "internet_gateway_id" {
  value = local.is_production ? aws_internet_gateway.ig[0].id : data.aws_internet_gateway.ig[0].id
}

output "public_subnets" {
  value = local.is_sandbox ? data.aws_subnet.public_subnets.*.id : aws_subnet.public_subnets.*.id
}

output "private_subnets" {
  value = local.is_sandbox ? data.aws_subnet.private_subnets.*.id : aws_subnet.private_subnets.*.id
}
