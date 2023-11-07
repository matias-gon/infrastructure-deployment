variable "vpc_name" {
  description = "The name of the VPC"
  default     = "vpc"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  description = "The CIDR block for the public subnets"
}

variable "private_subnet_cidr_blocks" {
  description = "The CIDR block for the private subnets"
}