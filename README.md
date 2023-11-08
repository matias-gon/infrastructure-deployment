**AWS Terraform Environment Setup for Web Application**

*Overview*

This repository contains Terraform configurations to set up a basic AWS environment for a web application. The infrastructure is spread across three AWS regions: Australia (AU), United Kingdom (UK), and United States (US). Each region hosts two separate environments: Production and Testing. The setup includes EC2 instances for hosting the web application and S3 buckets for storage.

![Architecture](https://github.com/matias-gon/infrastructure-deployment/assets/87095214/0e1ef9fa-6f9a-40d8-a3c4-b62beacf28f2)

*Prerequisites*
- You need an AWS account with permission to read and write to the S3 bucket for the remote state. [more info](https://developer.hashicorp.com/terraform/language/settings/backends/s3#s3-bucket-permissions)
- Ensure your AWS account has the necessary permissions to read and write to the DynamoDB table used for state locking.  [more info](https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-table-permissions)
- Install Terraform version 1.6 or later.
- Set up the AWS CLI with your credentials and select a default region.
- Have your public key files ready for use in folder public-keys. These keys must be provisioned through a secure channel.

*Structure*
The repository is organized with the following directory structure:
- `modules/`: Contains reusable Terraform modules for VPC, EC2, S3, and IAM permissions.
- `public-keys`: Should contain public keys that must be securely provisioned.
- `providers.tf`: Configures the AWS provider for each region.
- `variables.tf`: Defines variables used across the configurations.
- `outputs.tf`: Defines the output parameters of the infrastructure.

*Quick Start*

Create public-keys folder

```
mkdir public-keys
```

Copy public keys from secure repository

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

*Architecture Design Decisions*
- Region-Specific Providers: Each AWS region configures different AWS providers to comply with the multi-region requirement.
- Reusable Modules: The VPC, EC2, and S3 components are abstracted into modules for code reusability and better organization.
- EC2 Instances: All instances are t2.micro with Windows Server AMIs and 30GB storage, accessible from the public Internet.
- S3 Buckets: S3 buckets are created in the US region for each environment with read-write (RW) access for the respective EC2 instances.

*Security Best Practices*
- Minimal IAM Permissions: IAM roles and policies are crafted to grant the least privilege necessary to the EC2 instances.
- Security Groups: EC2 instances are associated with security groups that strictly allow only HTTP/HTTPS traffic for web access.
- Private S3 Buckets: S3 buckets are private with specific EC2 instance access, preventing unauthorized access.

*Contributing*
For any changes or improvements, please open an issue first to discuss what you would like to change. Ensure to update tests as appropriate.
