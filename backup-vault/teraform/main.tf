terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  backend "s3" {
    use_lockfile = true
    region       = "eu-west-2"
    key          = "ndr/terraform.tfstate"
    encrypt      = true
  }
}
provider "aws" {
  region = "eu-west-2"
}
