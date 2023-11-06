output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  value = [aws_subnet.private-subnet-1.id,aws_subnet.private-subnet-2.id]
}

output "public_subnet_ids" {
  value = [aws_subnet.public-subnet-1.id,aws_subnet.public-subnet-2.id]
}