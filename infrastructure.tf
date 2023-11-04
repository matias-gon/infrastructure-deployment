# Define the AWS provider for each region
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "vpc" {
  source = "./modules/VPC"
  vpc_name = "vpc-test"
  cidr_block = "10.0.0.0/16"
  public_subnet_cidr_block = "10.0.1.0/24"
  private_subnet_cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
}
