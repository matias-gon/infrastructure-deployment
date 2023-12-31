variable "environment" {
  description = "Enviroment"
  type        = string
  default     = "dev"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "The CIDR block for the public subnets"
}

variable "private_subnet_cidr_blocks" {
  description = "The CIDR block for the private subnets"
}