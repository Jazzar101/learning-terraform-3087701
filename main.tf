data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

resource "aws_instance" "test_instance" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "Test VMI"
  }
}

resource "aws_vpc" "test_vpc" {
	cidr_block = "10.0.0.0/16"
    enable_dns_support = true
	enable_dns_hostnames = true
	tags = {
		Name = "test_vpc"
	}
}
resource "aws_subnet" "test_subnet" {
	vpc_id = aws_vpc.test_vpc.id
	cidr_block = "10.0.1.0/24"
	map_public_ip_on_launch = true

	tags = {
		Name = "test_subnet"
	}
}
resource "aws_internet_gateway" "test_igw" {
	vpc_id = aws_vpc.test_vpc.id
	tags = {
		Name = "test_igw"
	}
}

resource "aws_route_table" "test_route" {
	vpc_id = aws_vpc.test_vpc.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.test_igw.id
	}
	tags = {
		Name = "test_route"
	}
}

resource "aws_route_table_association" "public_assoc" {
	subnet_id = aws_subnet.test_subnet.id
	route_table_id = aws_route_table.test_route.id
}

resource "aws_security_group" "test_group" {
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}
