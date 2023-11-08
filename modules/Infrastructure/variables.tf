variable "environment" {
  description = "The environment to deploy to"
  type        = string
  default     = "dev"
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR blocks for the VPC"
  type        = string
}

variable "ec2_instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "pub_key_file" {
  description = "The public key file"
  type        = string
}

variable "user_data_file" {
  description = "The user data file"
  type        = string
}

variable "autoscale_min" {
  description = "Minimum autoscale (number of EC2)"
  type        = number
  default     = "1"
}
variable "autoscale_max" {
  description = "Maximum autoscale (number of EC2)"
  type        = number
  default     = "1"
}
variable "autoscale_desired" {
  description = "Desired autoscale (number of EC2)"
  type        = number
  default     = "1"
}