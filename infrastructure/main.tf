# Terraform Config

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
  }
  backend "s3" {
    dynamodb_table = "ndr-terraform-locks"
    region         = "eu-west-2"
    key            = "ndr/terraform.tfstate"
    encrypt        = true
  }
}
provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Workspace = replace(terraform.workspace, "_", "-")
    }
  }
}

provider "awscc" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Workspace = replace(terraform.workspace, "_", "-")
    }
  }
}

resource "aws_resourcegroups_group" "resource_group" {
  name        = "${replace(terraform.workspace, "_", "-")}--resource-group"
  description = "${replace(terraform.workspace, "_", "-")} workspace resource group."
  tags = {
    Name      = "${replace(terraform.workspace, "_", "-")}--resource-group"
    Workspace = replace(terraform.workspace, "_", "-")
  }

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": ["AWS::AllSupported"],
  "TagFilters": [
    {
      "Key": "Workspace",
      "Values": ["${replace(terraform.workspace, "_", "-")}"]
    }
  ]
}
JSON
  }
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}

data "aws_elb_service_account" "main" {}

data "aws_ssm_parameter" "apim_url" {
  name = "/repo/${var.environment}/user-input/apim-api-url"
}

