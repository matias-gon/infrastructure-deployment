#AWS Terraform Environment Setup for Web Application

##Overview

This repository contains Terraform configurations to set up a basic AWS environment for a web application. The infrastructure is spread across three AWS regions: Australia (AU), United Kingdom (UK), and United States (US). Each region hosts two separate environments: Production and Testing. The setup includes EC2 instances for hosting the web application and S3 buckets for storage.

Prerequisites
AWS Account
Terraform v1.0 or newer
AWS CLI configured with access key, secret key, and a default region
Structure
The repository is organized with the following directory structure:

modules/: Contains reusable Terraform modules for VPC, EC2, S3, and IAM permissions.
environments/: Contains environment-specific configurations.
providers.tf: Configures the AWS provider.
variables.tf: Defines variables used across the configurations.
outputs.tf: Defines the output parameters of the infrastructure.
.terraform.lock.hcl: Tracks the exact provider versions used.
Quick Start
Initialize Terraform:

sh
Copy code
terraform init

Plan the Deployment:

Review the changes Terraform will make.

sh
Copy code
terraform plan

Apply the Configuration:

Apply the Terraform configuration to create the infrastructure.

sh
Copy code
terraform apply

Architecture Design Decisions
Region-Specific Providers: Different AWS providers are configured for each AWS region to comply with the multi-region requirement.
Reusable Modules: The VPC, EC2, and S3 components are abstracted into modules for code reusability and better organization.
EC2 Instances: All instances are t2.micro with Windows Server AMIs and 30GB storage, accessible from the public Internet.
S3 Buckets: S3 buckets are created in the US region for each environment with read-write (RW) access for the respective EC2 instances.

Security Best Practices
Minimal IAM Permissions: IAM roles and policies are crafted to grant the least privilege necessary to the EC2 instances.
Security Groups: EC2 instances are associated with security groups that strictly allow only HTTP/HTTPS traffic for web access.
Private S3 Buckets: S3 buckets are private with specific EC2 instance access, preventing unauthorized access.
Contributing
For any changes or improvements, please open an issue first to discuss what you would like to change. Ensure to update tests as appropriate.