variable "environment" {
  description = "Enviroment"
  type        = string
  default     = "dev"
}

variable "ec2_instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "ec2-instance"
}

variable "ec2_instance_type" {
  description = "Type of the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "pub_key_file" {
  description = "Public key file path"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "key_name" {
  description = "Name of the key pair"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile"
  type        = string
}

variable "health_check_path" {
  description = "Health check path for the default target group"
  type        = string
  default     = "/"
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

variable "user_data_file" {
  description = "User data file path"
  type        = string
  default     = "./user_data/user-data-dev.ps1"
}
