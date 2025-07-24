terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Owner       = var.owner
      Environment = var.environment
      Workspace   = replace(terraform.workspace, "_", "-")
    }
  }
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.standalone_vpc_tag}-vpc"
  }
}

locals {
  subnet_1_cidr_block = split(",", data.aws_ssm_parameter.virus_scanning_subnet_cidr_range.value)[0]
  subnet_2_cidr_block = split(",", data.aws_ssm_parameter.virus_scanning_subnet_cidr_range.value)[1]
}

resource "aws_subnet" "virus_scanning_subnet1" {
  availability_zone = "eu-west-2a"
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = local.subnet_1_cidr_block

  tags = {
    Name = "Virus scanning subnet for eu-west-2a"
  }
}

resource "aws_subnet" "virus_scanning_subnet2" {
  availability_zone = "eu-west-2b"
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = local.subnet_2_cidr_block

  tags = {
    Name = "Virus scanning subnet for eu-west-2b"
  }
}

data "aws_internet_gateway" "ig" {
  tags = {
    Name = "${var.standalone_vpc_ig_tag}-vpc-internet-gateway"
  }
}

resource "aws_route_table" "virus_scanning_route_table" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = data.aws_internet_gateway.ig.id
  }

  tags = {
    Name = "Virus scanning route table"
  }
}

resource "aws_route_table_association" "virus_scanning_subnet1_route_table_association" {
  subnet_id      = aws_subnet.virus_scanning_subnet1.id
  route_table_id = aws_route_table.virus_scanning_route_table.id
}

resource "aws_route_table_association" "virus_scanning_subnet2_route_table_association" {
  subnet_id      = aws_subnet.virus_scanning_subnet2.id
  route_table_id = aws_route_table.virus_scanning_route_table.id
}

data "aws_ssm_parameter" "cloud_security_admin_email" {
  name = "/prs/${var.cloud_security_email_param_environment}/user-input/cloud-security-admin-email"
}

data "aws_ssm_parameter" "virus_scanning_subnet_cidr_range" {
  name = "/prs/virus-scanner/subnet-cidr-range"
}

resource "aws_cloudformation_stack" "s3_virus_scanning_stack" {
  name = "s3-virus-scanning-cloudformation-stack"
  parameters = {
    VPC                                = data.aws_vpc.vpc.id
    SubnetA                            = aws_subnet.virus_scanning_subnet1.id
    SubnetB                            = aws_subnet.virus_scanning_subnet2.id
    ConsoleSecurityGroupCidrBlock      = var.public_address
    Email                              = data.aws_ssm_parameter.cloud_security_admin_email.value
    OnlyScanWhenQueueThresholdExceeded = "Yes"
    MinRunningAgents                   = 0
    NumMessagesInQueueScalingThreshold = 1
    AllowAccessToAllKmsKeys            = "No"
  }
  timeouts {
    create = "60m"
    delete = "2h"
  }
  tags = {
    Name = "Virus scanner for Repository"
  }
  template_url = "https://css-cft.s3.amazonaws.com/ConsoleCloudFormationTemplate.yaml"
  capabilities = ["CAPABILITY_NAMED_IAM"]
}
