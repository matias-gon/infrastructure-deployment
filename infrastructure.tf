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

module "vpc" {
  providers = {
    aws = aws.AU
  }
  source = "./modules/VPC"
  vpc_name = "vpc-test"
  cidr_block = "10.0.0.0/16"
  public_subnet_cidr_block = "10.0.1.0/24"
  private_subnet_cidr_block = "10.0.2.0/24"
}

module "permission" {
  providers = {
    aws = aws.AU
  }
  source = "./modules/Permission"
}

module "ec2"{
  providers = {
    aws = aws.AU
  }
  source = "./modules/EC2"
  ec2_instance_name = "ec2-test"
  ec2_instance_type = "t2.micro"
  vpc_id = module.vpc.vpc_id
  private_subnet_id = module.vpc.private_subnet_id
  public_subnet_id = module.vpc.public_subnet_id
  iam_instance_profile = module.permission.aws_iam_instance_profile_id
}
