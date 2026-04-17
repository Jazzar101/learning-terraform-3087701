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


resource "aws_security_group" "public_group" {
  name   = "Public Group"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_group" {
  name   = "Private Group"
  vpc_id = aws_vpc.main_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "monitoring" {
  name   = "Monitoring"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "allow_directus" {
  type              = "ingress"
  security_group_id = aws_security_group.private_group.id
  from_port         = 8055
  to_port           = 8055
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.nginx_instance.private_ip}/32", "${aws_instance.api_test_instance.private_ip}/32"]
}

resource "aws_security_group_rule" "allow_mysql" {
  type              = "ingress"
  security_group_id = aws_security_group.private_group.id
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.web_app_instance.private_ip}/32"]
}

resource "aws_security_group_rule" "allow_cadvisor_metrics" {
  type              = "ingress"
  security_group_id = aws_security_group.private_group.id
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.monitoring_instance.private_ip}/32"]
}

resource "aws_security_group_rule" "allow_node_metrics" {
  type              = "ingress"
  security_group_id = aws_security_group.private_group.id
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.monitoring_instance.private_ip}/32"]
}

resource "aws_security_group_rule" "allow_ssh_from_nginx" {
  type              = "ingress"
  security_group_id = aws_security_group.private_group.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.nginx_instance.private_ip}/32"]
}

resource "aws_key_pair" "main_key" {
  key_name   = "id_rsa"
  public_key = var.main_key
}

resource "aws_instance" "database_instance" {
  ami             = "ami-0c17cb8e234335014"
  instance_type   = var.instance_type
  key_name        = "id_rsa"
  subnet_id       = aws_subnet.secret_subnet.id
  security_groups = [aws_security_group.private_group.id]
  tags = {
    Name = "Database"
  }
}

resource "aws_instance" "web_app_instance" {
  ami             = "ami-0c17cb8e234335014"
  instance_type   = var.instance_type
  key_name        = "id_rsa"
  subnet_id       = aws_subnet.secret_subnet.id
  security_groups = [aws_security_group.private_group.id]
  tags = {
    Name = "Web App"
  }
}

resource "aws_instance" "api_test_instance" {
  ami                         = "ami-0c17cb8e234335014"
  instance_type               = var.instance_type
  key_name                    = "id_rsa"
  subnet_id                   = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.public_group.id]
  tags = {
    Name = "API Tests"
  }
}

resource "aws_instance" "monitoring_instance" {
  ami                         = "ami-0c17cb8e234335014"
  instance_type               = var.instance_type
  key_name                    = "id_rsa"
  subnet_id                   = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.public_group.id, aws_security_group.monitoring.id]
  tags = {
    Name = "Monitoring"
  }
}

resource "aws_instance" "nginx_instance" {
  ami                         = "ami-0c17cb8e234335014"
  instance_type               = var.instance_type
  key_name                    = "id_rsa"
  subnet_id                   = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.public_group.id]
  tags = {
    Name = "Nginx"
  }
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    database_private_ip  = aws_instance.database_instance.private_ip
    web_app_private_ip   = aws_instance.web_app_instance.private_ip
    api_test_public_ip   = aws_instance.api_test_instance.public_ip
    monitoring_public_ip = aws_instance.monitoring_instance.public_ip
    nginx_public_ip      = aws_instance.nginx_instance.public_ip
  })
  filename = "/etc/ansible/hosts"
}

resource "local_file" "compose" {
  content = templatefile("${path.module}/../roles/deploy_services/templates/web-app-docker-compose.yml.tpl", {
    database_private_ip = aws_instance.database_instance.private_ip
    web_app_private_ip  = aws_instance.web_app_instance.private_ip
  })
  filename = "../roles/deploy_services/files/app-docker-compose.yml"
}

resource "local_file" "api_tests_python" {
  content = templatefile("${path.module}/../roles/run_tests/templates/run_tests.py.tpl", {
    nginx_private_ip = aws_instance.nginx_instance.public_ip
  })
  filename = "../roles/run_tests/files/run_tests.py"
}

resource "local_file" "api_tests_tasks" {
  content = templatefile("${path.module}/../roles/run_tests/templates/main.yml.tpl", {
    nginx_private_ip = aws_instance.nginx_instance.private_ip
  })
  filename = "../roles/run_tests/tasks/main.yml"
}

resource "local_file" "nginx_config" {
  content = templatefile("${path.module}/../roles/configure_nginx/templates/nginx.conf.tpl", {
    web_app_private_ip = aws_instance.web_app_instance.private_ip
  })
  filename = "../roles/configure_nginx/files/nginx.conf"
}
