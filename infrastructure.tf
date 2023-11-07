terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Enviroments
variable "environments" {
  type    = list(string)
  default = ["production", "testing"]
}

# VPC CIDR Blocks for each region and enviroment
variable "vpc_cidr_blocks" {
  type    = map(string)
  default = {
    "AU-production" = "10.1.0.0/16"
    "AU-testing"    = "10.2.0.0/16"
    "UK-production" = "10.3.0.0/16"
    "UK-testing"    = "10.4.0.0/16"
    "US-production" = "10.5.0.0/16"
    "US-testing"    = "10.6.0.0/16"
  }
}

# Infrastructure for AU Region
module "vpc_au" {
  for_each                   = toset(var.environments)
  
  providers = {
    aws = aws.AU
  }
  source                     = "./modules/VPC"

  enviroment                 = each.value
  cidr_block                 = var.vpc_cidr_blocks["AU-${each.value}"]
  public_subnet_cidr_blocks  = ["${cidrsubnet(var.vpc_cidr_blocks["AU-${each.value}"], 8, 1)}","${cidrsubnet(var.vpc_cidr_blocks["AU-${each.value}"], 8, 2)}"]
  private_subnet_cidr_blocks = ["${cidrsubnet(var.vpc_cidr_blocks["AU-${each.value}"], 8, 3)}","${cidrsubnet(var.vpc_cidr_blocks["AU-${each.value}"], 8, 4)}"]
}

module "permission_s3_au" {
  for_each   = toset(var.environments)
  
  providers = {
    aws = aws.US
  }
  source     = "./modules/Permission"

  region     = "au"
  enviroment = each.value
}

module "ec2_au" {
  for_each             = toset(var.environments)
  
  providers = {
    aws = aws.AU
  }
  source               = "./modules/EC2"
  
  ec2_instance_name    = "ec2-${each.value}"
  ec2_instance_type    = "t2.micro"
  vpc_id               = module.vpc_au[each.value].vpc_id
  private_subnet_ids   = module.vpc_au[each.value].private_subnet_ids
  public_subnet_ids    = module.vpc_au[each.value].public_subnet_ids
  iam_instance_profile = module.permission_s3_au[each.value].aws_iam_instance_profile_id
}

# Infrastructure for UK Region
module "vpc_uk" {
  for_each                   = toset(var.environments)
  
  providers = {
    aws = aws.UK
  }
  source                     = "./modules/VPC"
  
  enviroment                 = each.value
  cidr_block                 = var.vpc_cidr_blocks["UK-${each.value}"]
  public_subnet_cidr_blocks  = ["${cidrsubnet(var.vpc_cidr_blocks["UK-${each.value}"], 8, 1)}","${cidrsubnet(var.vpc_cidr_blocks["UK-${each.value}"], 8, 2)}"]
  private_subnet_cidr_blocks = ["${cidrsubnet(var.vpc_cidr_blocks["UK-${each.value}"], 8, 3)}","${cidrsubnet(var.vpc_cidr_blocks["UK-${each.value}"], 8, 4)}"]
}

module "permission_s3_uk" {
  for_each   = toset(var.environments)

  providers = {
    aws = aws.US
  }
  source     = "./modules/Permission"
  
  region     = "uk"
  enviroment = each.value
}

module "ec2_uk" {
  for_each             = toset(var.environments)
  
  providers = {
    aws = aws.UK
  }
  source               = "./modules/EC2"
  
  ec2_instance_name    = "ec2-${each.value}"
  ec2_instance_type    = "t2.micro"
  vpc_id               = module.vpc_uk[each.value].vpc_id
  private_subnet_ids   = module.vpc_uk[each.value].private_subnet_ids
  public_subnet_ids    = module.vpc_uk[each.value].public_subnet_ids
  iam_instance_profile = module.permission_s3_uk[each.value].aws_iam_instance_profile_id
}

# Infrastructure for US Region
module "vpc_us" {
  for_each                   = toset(var.environments)

  providers = {
    aws = aws.US
  }
  source                     = "./modules/VPC"
  
  enviroment                 = each.value
  cidr_block                 = var.vpc_cidr_blocks["US-${each.value}"]
  public_subnet_cidr_blocks  = ["${cidrsubnet(var.vpc_cidr_blocks["US-${each.value}"], 8, 1)}","${cidrsubnet(var.vpc_cidr_blocks["US-${each.value}"], 8, 2)}"]
  private_subnet_cidr_blocks = ["${cidrsubnet(var.vpc_cidr_blocks["US-${each.value}"], 8, 3)}","${cidrsubnet(var.vpc_cidr_blocks["US-${each.value}"], 8, 4)}"]
}

module "permission_s3_us" {
  for_each   = toset(var.environments)
  
  providers = {
    aws = aws.US
  }
  source     = "./modules/Permission"
  
  region     = "us"
  enviroment = each.value
}

module "ec2_us" {
  for_each             = toset(var.environments)

  providers = {
    aws = aws.US
  }
  source               = "./modules/EC2"
  
  ec2_instance_name    = "ec2-${each.value}"
  ec2_instance_type    = "t2.micro"
  vpc_id               = module.vpc_us[each.value].vpc_id
  private_subnet_ids   = module.vpc_us[each.value].private_subnet_ids
  public_subnet_ids    = module.vpc_us[each.value].public_subnet_ids
  iam_instance_profile = module.permission_s3_us[each.value].aws_iam_instance_profile_id
}