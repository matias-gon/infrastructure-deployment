terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block # Replace with your desired CIDR block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.public_subnet_cidr_block # Replace with your desired CIDR block
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidr_block # Replace with your desired CIDR block
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "private_subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_eip" "nat_gateway" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}
resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "NAT Gateway"
  }
  depends_on = [aws_eip.nat_gateway]
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-route-table"
  }
}
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-route-table"
  }
}

# Route the public subnet traffic through the Internet Gateway
resource "aws_route" "public-internet-igw-route" {
  route_table_id         = aws_route_table.public-route-table.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Route NAT Gateway
resource "aws_route" "nat-ngw-route" {
  route_table_id         = aws_route_table.private-route-table.id
  nat_gateway_id         = aws_nat_gateway.ngw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Associate the public subnet with the public route table
resource "aws_route_table_association" "public-route-table-assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public-route-table.id
}

# Associate the private subnet with the private route table
resource "aws_route_table_association" "private-route-table-assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private-route-table.id
}