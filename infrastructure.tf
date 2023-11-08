terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# environments
variable "environments" {
  type    = list(string)
  default = ["production", "testing"]
}

# VPC CIDR Blocks for each region and environment
variable "vpc_cidr_blocks" {
  type = map(string)
  default = {
    "AU-production" = "10.1.0.0/16"
    "AU-testing"    = "10.2.0.0/16"
    "UK-production" = "10.3.0.0/16"
    "UK-testing"    = "10.4.0.0/16"
    "US-production" = "10.5.0.0/16"
    "US-testing"    = "10.6.0.0/16"
  }
}

module "infrastructure_au" {
  for_each = toset(var.environments)

  providers = {
    aws = aws.AU
  }
  source = "./modules/Infrastructure"

  environment    = each.value
  vpc_cidr_block = var.vpc_cidr_blocks["AU-${each.value}"]
  region         = "au"
  pub_key_file   = "./public-keys/id_rsa_au_${each.value}.pub"
  user_data_file = "./user-data/user_data_${each.value}.ps1"

}

module "infrastructure_uk" {
  for_each = toset(var.environments)

  providers = {
    aws = aws.UK
  }
  source = "./modules/Infrastructure"

  environment    = each.value
  vpc_cidr_block = var.vpc_cidr_blocks["UK-${each.value}"]
  region         = "uk"
  pub_key_file   = "./public-keys/id_rsa_uk_${each.value}.pub"
  user_data_file = "./user-data/user_data_${each.value}.ps1"

}

module "infrastructure_us" {
  for_each = toset(var.environments)

  providers = {
    aws = aws.US
  }
  source = "./modules/Infrastructure"

  environment    = each.value
  vpc_cidr_block = var.vpc_cidr_blocks["US-${each.value}"]
  region         = "us"
  pub_key_file   = "./public-keys/id_rsa_us_${each.value}.pub"
  user_data_file = "./user-data/user_data_${each.value}.ps1"

}

