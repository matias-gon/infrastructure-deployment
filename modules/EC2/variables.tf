variable "ec2_instance_name" {}

variable "ec2_instance_type" {}

variable "vpc_id" {}

variable "private_subnet_ids" {}

variable "public_subnet_ids" {}

variable "iam_instance_profile" {}

variable "health_check_path" {
  description = "Health check path for the default target group"
  default     = "/"
}

variable "autoscale_min" {
  description = "Minimum autoscale (number of EC2)"
  default     = "1"
}
variable "autoscale_max" {
  description = "Maximum autoscale (number of EC2)"
  default     = "1"
}
variable "autoscale_desired" {
  description = "Desired autoscale (number of EC2)"
  default     = "1"
}
