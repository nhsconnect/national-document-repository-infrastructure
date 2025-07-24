resource "aws_security_group" "ndr_ecs_sg" {
  name        = var.sg_name
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id
  tags = {
    Name = var.sg_name
  }
}

resource "aws_vpc_security_group_egress_rule" "ndr_ecs_sg_egress_http" {
  security_group_id = aws_security_group.ndr_ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ndr_ecs_sg_ingress_http" {
  security_group_id = aws_security_group.ndr_ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "ndr_ecs_sg_egress_https" {
  security_group_id = aws_security_group.ndr_ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "ndr_ecs_sg_ingress_https" {
  security_group_id = aws_security_group.ndr_ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
