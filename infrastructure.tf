# Define the AWS provider for each region
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Define the regions
/* variable "regions" {
  type    = list(string)
  default = ["au", "uk", "us"]
}

# Define the environments
variable "environments" {
  type    = list(string)
  default = ["production", "testing"]
} */

variable "environments" {
  type    = list(string)
  default = ["production", "testing"]
}

module "permission" {
  providers = {
    aws = aws.AU
  }
  source = "./modules/Permission"
}

module "vpc-au" {
  providers = {
    aws = aws.AU
  }
  for_each = toset(var.environments)
  source = "./modules/VPC"
  vpc_name = "vpc-${each.value}"
  cidr_block = "10.1.0.0/16"
  public_subnet_cidr_block = "10.1.1.0/24"
  private_subnet_cidr_block = "10.1.2.0/24"
}

 module "ec2-au"{
  providers = {
    aws = aws.AU
  }
  source = "./modules/EC2"
  for_each = toset(var.environments)
  ec2_instance_name = "ec2-${each.value}"
  ec2_instance_type = "t2.micro"
  vpc_id = module.vpc-au[each.value].vpc_id
  private_subnet_id = module.vpc-au[each.value].private_subnet_id
  public_subnet_id = module.vpc-au[each.value].public_subnet_id
  iam_instance_profile = module.permission.aws_iam_instance_profile_id
}

module "vpc-uk" {
  providers = {
    aws = aws.UK
  }
  for_each = toset(var.environments)
  source = "./modules/VPC"
  vpc_name = "vpc-${each.value}"
  cidr_block = "10.2.0.0/16"
  public_subnet_cidr_block = "10.2.1.0/24"
  private_subnet_cidr_block = "10.2.2.0/24"
}

 module "ec2-uk"{
  providers = {
    aws = aws.UK
  }
  source = "./modules/EC2"
  for_each = toset(var.environments)
  ec2_instance_name = "ec2-${each.value}"
  ec2_instance_type = "t2.micro"
  vpc_id = module.vpc-uk[each.value].vpc_id
  private_subnet_id = module.vpc-uk[each.value].private_subnet_id
  public_subnet_id = module.vpc-uk[each.value].public_subnet_id
  iam_instance_profile = module.permission.aws_iam_instance_profile_id
}

module "vpc-us" {
  providers = {
    aws = aws.US
  }
  for_each = toset(var.environments)
  source = "./modules/VPC"
  vpc_name = "vpc-${each.value}"
  cidr_block = "10.3.0.0/16"
  public_subnet_cidr_block = "10.3.1.0/24"
  private_subnet_cidr_block = "10.3.2.0/24"
}

 module "ec2-us"{
  providers = {
    aws = aws.US
  }
  source = "./modules/EC2"
  for_each = toset(var.environments)
  ec2_instance_name = "ec2-${each.value}"
  ec2_instance_type = "t2.micro"
  vpc_id = module.vpc-us[each.value].vpc_id
  private_subnet_id = module.vpc-us[each.value].private_subnet_id
  public_subnet_id = module.vpc-us[each.value].public_subnet_id
  iam_instance_profile = module.permission.aws_iam_instance_profile_id
}