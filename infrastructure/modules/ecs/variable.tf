variable "vpc_id" {
  type = string
}

variable "sg_name" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_cluster_service_name" {
  type = string
}

variable "ecs_launch_type" {
  type    = string
  default = "FARGATE"
}

variable "public_subnets" {
}

variable "private_subnets" {
}

variable "aws_region" {
  type    = string
  default = "eu-west-2"
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "ecr_repository_url" {
}

variable "domain" {
  type = string
}

variable "certificate_domain" {
  type = string
}

variable "container_port" {
  type    = number
  default = 8080
}

output "dns_name" {
  value = aws_lb.ecs_lb.dns_name
}

output "security_group_id" {
  value = aws_security_group.ndr_ecs_sg.id
}
