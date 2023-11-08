terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# VPC per environment
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block 
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc - ${var.environment}"
    Environment = var.environment
  }
}

# Search for AZs available in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Create public and private subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public_subnet_1_${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[1]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public_subnet_2_${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private_subnet_1_${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[1]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private_subnet_2_${var.environment}"
    Environment = var.environment
  }
}

# Create Internet Gateway and NAT Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW - ${var.environment}"
    Environment = var.environment
  }
}

resource "aws_eip" "nat_gateway" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "NAT Gateway - ${var.environment}"
    Environment = var.environment
  }
}

# Create public and private route tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-route-table-${var.environment}"
    Environment = var.environment
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-route-table-${var.environment}"
    Environment = var.environment
  }
}

# Route the public subnet traffic through the Internet Gateway
resource "aws_route" "public_internet_igw_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route NAT Gateway
resource "aws_route" "nat_ngw_route" {
  route_table_id         = aws_route_table.private_route_table.id
  nat_gateway_id         = aws_nat_gateway.ngw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Associate the public subnets with the public route table
resource "aws_route_table_association" "public_route_table_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_table_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate the private subnets with the private route table
resource "aws_route_table_association" "private_route_table_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_route_table_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}