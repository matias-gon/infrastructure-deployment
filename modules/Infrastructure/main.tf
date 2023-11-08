terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Infrastructure for AU Region
module "vpc" {
  source = "../VPC"

  environment                = var.environment
  cidr_block                 = var.vpc_cidr_block
  public_subnet_cidr_blocks  = [cidrsubnet(var.vpc_cidr_block, 8, 1), cidrsubnet(var.vpc_cidr_block, 8, 2)]
  private_subnet_cidr_blocks = [cidrsubnet(var.vpc_cidr_block, 8, 3), cidrsubnet(var.vpc_cidr_block, 8, 4)]
}

module "permission_s3" {
  source = "../Permission"

  region      = lower(var.region)
  environment = var.environment
}

module "ec2" {
  source = "../EC2"

  ec2_instance_name    = "web-${var.region}-${var.environment}"
  ec2_instance_type    = var.ec2_instance_type
  key_name             = "key-${var.region}-${var.environment}"
  pub_key_file         = var.pub_key_file
  user_data_file       = var.user_data_file
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnet_ids
  iam_instance_profile = module.permission_s3.aws_iam_instance_profile_name
}