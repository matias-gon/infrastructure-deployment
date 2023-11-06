# Define the AWS provider for each region
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "environments" {
  type    = list(string)
  default = ["production"]#, "testing"]
}

module "vpc-au" {
  providers = {
    aws = aws.AU
  }
  for_each                  = toset(var.environments)
  source                    = "./modules/VPC"
  vpc_name                  = "vpc-${each.value}"
  cidr_block                = "10.1.0.0/16"
  public_subnet_cidr_block  = ["10.1.1.0/24","10.1.2.0/24"]
  private_subnet_cidr_block = ["10.1.3.0/24","10.1.4.0/24"]
}

module "permission-au" {
  providers = {
    aws = aws.US
  }
  source     = "./modules/Permission"
  for_each   = toset(var.environments)
  region     = "au"
  enviroment = each.value
}

module "ec2-au" {
  providers = {
    aws = aws.AU
  }
  source               = "./modules/EC2"
  for_each             = toset(var.environments)
  ec2_instance_name    = "ec2-${each.value}"
  ec2_instance_type    = "t2.micro"
  vpc_id               = module.vpc-au[each.value].vpc_id
  private_subnet_ids    = module.vpc-au[each.value].private_subnet_ids
  public_subnet_ids     = module.vpc-au[each.value].public_subnet_ids
  iam_instance_profile = module.permission-au[each.value].aws_iam_instance_profile_id
}

module "vpc-uk" {
  providers = {
    aws = aws.UK
  }
  for_each                  = toset(var.environments)
  source                    = "./modules/VPC"
  vpc_name                  = "vpc-${each.value}"
  cidr_block                = "10.2.0.0/16"
  public_subnet_cidr_block  = ["10.2.1.0/24","10.2.2.0/24"]
  private_subnet_cidr_block = ["10.2.3.0/24","10.2.4.0/24"]
}

module "permission-uk" {
  providers = {
    aws = aws.US
  }
  source     = "./modules/Permission"
  for_each   = toset(var.environments)
  region     = "uk"
  enviroment = each.value
}

module "ec2-uk" {
  providers = {
    aws = aws.UK
  }
  source               = "./modules/EC2"
  for_each             = toset(var.environments)
  ec2_instance_name    = "ec2-${each.value}"
  ec2_instance_type    = "t2.micro"
  vpc_id               = module.vpc-uk[each.value].vpc_id
  private_subnet_ids   = module.vpc-uk[each.value].private_subnet_ids
  public_subnet_ids    = module.vpc-uk[each.value].public_subnet_ids
  iam_instance_profile = module.permission-uk[each.value].aws_iam_instance_profile_id
}

module "vpc-us" {
  providers = {
    aws = aws.US
  }
  for_each                  = toset(var.environments)
  source                    = "./modules/VPC"
  vpc_name                  = "vpc-${each.value}"
  cidr_block                = "10.3.0.0/16"
  public_subnet_cidr_block  = ["10.3.1.0/24","10.3.2.0/24"]
  private_subnet_cidr_block = ["10.3.3.0/24","10.3.4.0/24"]
}

module "permission-us" {
  providers = {
    aws = aws.US
  }
  source     = "./modules/Permission"
  for_each   = toset(var.environments)
  region     = "us"
  enviroment = each.value
}

module "ec2-us" {
  providers = {
    aws = aws.US
  }
  source               = "./modules/EC2"
  for_each             = toset(var.environments)
  ec2_instance_name    = "ec2-${each.value}"
  ec2_instance_type    = "t2.micro"
  vpc_id               = module.vpc-us[each.value].vpc_id
  private_subnet_ids   = module.vpc-us[each.value].private_subnet_ids
  public_subnet_ids    = module.vpc-us[each.value].public_subnet_ids
  iam_instance_profile = module.permission-us[each.value].aws_iam_instance_profile_id
}