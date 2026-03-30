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

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route.id
}

resource "aws_security_group" "main_group" {
  name   = "main_group"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2368
    to_port     = 2368
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "main_key" {
  key_name   = "id_rsa"
  public_key = var.main_key
}

resource "aws_instance" "database_instance" {
  ami                         = "ami-0c17cb8e234335014"
  instance_type               = var.instance_type
  key_name                    = "id_rsa"
  subnet_id                   = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.main_group.id]
  tags = {
    Name = var.database_instance_name
  }
}

resource "aws_instance" "web_app_instance" {
  ami                         = "ami-0c17cb8e234335014"
  instance_type               = var.instance_type
  key_name                    = "id_rsa"
  subnet_id                   = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.main_group.id]
  tags = {
    Name = var.web_app_instance_name
  }
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    database_public_ip = aws_instance.database_instance.public_ip
    web_app_public_ip  = aws_instance.web_app_instance.public_ip
  })
  filename = "/etc/ansible/hosts"
}

resource "local_file" "compose" {
  content = templatefile("${path.module}/templates/web-app-docker-compose.tpl", {
    database_public_ip = aws_instance.database_instance.public_ip
    web_app_public_ip  = aws_instance.web_app_instance.public_ip
  })
  filename = "./playbooks/web-app-docker-compose.yml"
}

