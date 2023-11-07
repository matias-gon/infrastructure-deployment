**AWS Terraform Environment Setup for Web Application**

*Overview*

This repository contains Terraform configurations to set up a basic AWS environment for a web application. The infrastructure is spread across three AWS regions: Australia (AU), United Kingdom (UK), and United States (US). Each region hosts two separate environments: Production and Testing. The setup includes EC2 instances for hosting the web application and S3 buckets for storage.

![Architecture](https://github.com/matias-gon/infrastructure-deployment/assets/87095214/0e1ef9fa-6f9a-40d8-a3c4-b62beacf28f2)

*Prerequisites*

- AWS Account with read and write access to S3 bucket where the remote state is located. [more info](https://developer.hashicorp.com/terraform/language/settings/backends/s3#s3-bucket-permissions)
- AWS Account with read and write access to Dynamodb table where state lock is storage. [more info](https://developer.hashicorp.com/terraform/language/settings/backends/s3#dynamodb-table-permissions)
- Terraform v1.0 or newer
- AWS CLI configured with access key, secret key, and a default region
- Public key file key.pub

*Structure*
The repository is organized with the following directory structure:
- modules/: Contains reusable Terraform modules for VPC, EC2, S3, and IAM permissions.
- providers.tf: Configures the AWS provider for each region.
- variables.tf: Defines variables used across the configurations.
- outputs.tf: Defines the output parameters of the infrastructure.

*Quick Start*

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

*Architecture Design Decisions*
- Region-Specific Providers: Different AWS providers are configured for each AWS region to comply with the multi-region requirement.
- Reusable Modules: The VPC, EC2, and S3 components are abstracted into modules for code reusability and better organization.
- EC2 Instances: All instances are t2.micro with Windows Server AMIs and 30GB storage, accessible from the public Internet.
- S3 Buckets: S3 buckets are created in the US region for each environment with read-write (RW) access for the respective EC2 instances.

*Security Best Practices*
- Minimal IAM Permissions: IAM roles and policies are crafted to grant the least privilege necessary to the EC2 instances.
- Security Groups: EC2 instances are associated with security groups that strictly allow only HTTP/HTTPS traffic for web access.
- Private S3 Buckets: S3 buckets are private with specific EC2 instance access, preventing unauthorized access.

*Contributing*
For any changes or improvements, please open an issue first to discuss what you would like to change. Ensure to update tests as appropriate.
