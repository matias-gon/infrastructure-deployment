# **AWS Terraform Environment Setup for Web Application**

## *Overview*

This repository contains Terraform configurations to set up a basic AWS environment for a web application. The infrastructure is spread across three AWS regions: Australia (AU), United Kingdom (UK), and United States (US). Each region hosts two separate environments: Production and Testing. The setup includes EC2 instances for hosting the web application, S3 buckets for storage, and Application Load Balancer for Website publishing.

![Architecture](https://github.com/matias-gon/infrastructure-deployment/assets/87095214/93fae503-8a6a-4b5e-9495-066cdd4e1e12)

## *Prerequisites*
- You need an AWS account with permission to read and write to the S3 bucket for the remote state. [more info](https://developer.hashicorp.com/terraform/language/settings/backends/s3#s3-bucket-permissions)
- Ensure your AWS account has the necessary permissions to read and write to the DynamoDB table used for state locking.  [more info](https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-table-permissions)
- Install Terraform version 1.6 or later.
- Set up the AWS CLI with your credentials and select a default region.
- Have your public key files ready for use in folder public-keys. These keys must be provisioned through a secure channel.

## *Structure*

The repository is organized with the following directory structure:
- `modules/`: Contains reusable Terraform modules for Infrastructure, VPC, EC2, S3, and IAM permissions.
- `public-keys/`: Should contain public keys securely provisioned.
  - File name format: id_rsa_\<region\>_\<environment\>.pub.
  - Example: id_rsa_au_production.pub
- `user-data/`: Contains PowerShell scripts to pass as user data to EC2 instances on each environment.
  - File name format: user_data_\<environment\>.ps1
  - Example: user_data_production.ps1
- `providers.tf`: Configures the AWS provider for each region.
- `variables.tf`: Defines variables used across the configurations.
- `outputs.tf`: Defines the output parameters of the infrastructure.

## *Quick Start*

Create public-keys folder

```
mkdir public-keys
```

Copy provisioned public keys

Initialize Terraform: prepares your workspace so Terraform can apply your configuration

```
terraform init
```

Plan the Deployment: Review the changes Terraform will make.

```
terraform plan
```

Apply the Configuration: Apply the Terraform configuration to create the infrastructure.

```
terraform apply
```

Outputs: Get the DNS names of the Application Load Balancer.

```
terraform output
```
## *Create a new environment*

For a new environment creation (e.g. QA), add the following resources:

- The new environment name in the `environment` variable in `infrastructure.tf` file

```
# Adding QA environment
variable "environments" {
  type    = list(string)
  default = ["production", "testing", "QA"]
}
```
-  The new environment CIDR block in the `vpc_cidr_blocks` in `infrastructure.tf` file
```
variable "vpc_cidr_blocks" {
  type = map(string)
  default = {
    "AU-production" = "10.1.0.0/16"
    "AU-testing"    = "10.2.0.0/16"
    "AU-QA"         = "10.7.0.0/16"
    "UK-production" = "10.3.0.0/16"
    "UK-testing"    = "10.4.0.0/16"
    "UK-QA"         = "10.8.0.0/16"
    "US-production" = "10.5.0.0/16"
    "US-testing"    = "10.6.0.0/16"
    "US-QA"         = "10.9.0.0/16"
  }
}
```
- The new environment public key file in `public-keys` folder for each region
  - id_rsa_au_QA.pub
  - id_rsa_uk_QA.pub
  - id_rsa_us_QA.pub
- The new environment configuration script in `user-data` folder
  - user_data_QA.ps1

## *Deployment in a new Region*

Extend the deployment to a new region (e.g. Japan - JP) requires the following resources:

- Create a new `provider` in `providers.tf` file
```
provider "aws" {
  region = "ap-northeast-1"
  alias  = "JP"
}
```
-  The new region CIDR block in the `vpc_cidr_blocks` in `infrastructure.tf` file for each environment
```
variable "vpc_cidr_blocks" {
  type = map(string)
  default = {
    "AU-production" = "10.1.0.0/16"
    "AU-testing"    = "10.2.0.0/16"
    "UK-production" = "10.3.0.0/16"
    "UK-testing"    = "10.4.0.0/16"
    "UK-QA"         = "10.8.0.0/16"
    "US-production" = "10.5.0.0/16"
    "US-testing"    = "10.6.0.0/16"
    "JP-production" = "10.7.0.0/16"
    "JP-testing"    = "10.8.0.0/16"
  }
}
```
- A new infrastructure module in `infrastructure.tf` file
```
module "infrastructure_jp" {
  for_each = toset(var.environments)

  providers = {
    aws = aws.JP
  }
  source = "./modules/Infrastructure"

  environment    = each.value
  vpc_cidr_block = var.vpc_cidr_blocks["JP-${each.value}"]
  region         = "jp"
  pub_key_file   = "./public-keys/id_rsa_jp_${each.value}.pub"
  user_data_file = "./user-data/user_data_${each.value}.ps1"
}
```
- A new output resource in `outputs.tf` file for each environment
```
output "alb_dns_name_jp_production" {
  description = "The DNS name of the ALB"
  value       = module.infrastructure_jp["production"].alb_dns_name
}

output "alb_dns_name_jp_testing" {
  description = "The DNS name of the ALB"
  value       = module.infrastructure_jp["testing"].alb_dns_name
}
```
- The new region public key files in `public-keys` folder for each environment
  - id_rsa_jp_production.pub
  - id_rsa_jp_testing.pub
 
## *Architecture Design Decisions*
- Region-Specific Providers: Each AWS region configures different AWS providers to comply with the multi-region requirement.
- Reusable Modules: The VPC, EC2, and S3 components are abstracted into modules for code reusability and better organization.
- EC2 Instances: All instances are t2.micro with Windows Server AMIs and 30GB storage, accessible from the public Internet.
- S3 Buckets: S3 buckets are created in the US region for each environment with read-write (RW) access for the respective EC2 instances.

## *Security Best Practices*
- Minimal IAM Permissions: IAM roles and policies are crafted to grant the least privilege necessary to the EC2 instances.
- Security Groups: EC2 instances are associated with security groups that strictly allow only HTTP traffic for web access.
- Private S3 Buckets: S3 buckets are private with specific EC2 instance access, preventing unauthorized access.

*Contributing*
For any changes or improvements, please open an issue first to discuss what you would like to change. Ensure to update tests as appropriate.
