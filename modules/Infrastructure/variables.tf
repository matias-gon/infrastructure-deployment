variable "environment" {
  description = "The environment to deploy to"
  default     = "dev"
}

variable "region" {
  description = "The region to deploy to"
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR blocks for the VPC"
}

variable "ec2_instance_type" {
  description = "The EC2 instance type"
  default     = "t2.micro"
}

variable "pub_key_file" {
  description = "The public key file"
}

variable "user_data_file" {
  description = "The user data file"
}