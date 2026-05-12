resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.main_subnet.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = var.main_subnet.name
  }
}

resource "aws_subnet" "secret_subnet" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.secret_subnet.subnet_cidr
  tags = {
    Name = var.secret_subnet.name
  }
}
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "main_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "main_route"
  }
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.secret_subnet.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_eip" "elastic_ip" {
  domain = "vpc"

  tags = {
    Name = "NAT Elastic IP"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.main_subnet.id

  depends_on = [
    aws_internet_gateway.main_igw
  ]

  tags = {
    Name = "NAT Gateway"
  }
}

resource "aws_key_pair" "main_key" {
  key_name   = "id_rsa.pub"
  public_key = var.main_key
}

