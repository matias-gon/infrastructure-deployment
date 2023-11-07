output "vpc_id" {
  description = "The ID of the VPC"
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}