resource "aws_instance" "database_instance" {
  ami                    = "ami-0c17cb8e234335014"
  instance_type          = var.instance_type
  key_name               = "id_rsa"
  subnet_id              = aws_subnet.secret_subnet.id
  vpc_security_group_ids = [aws_security_group.private_group.id, aws_security_group.ssh_from_testing.id]
  tags = {
    Name = "Database"
  }
}

resource "aws_instance" "web_app_instance" {
  ami                    = "ami-0c17cb8e234335014"
  instance_type          = var.instance_type
  key_name               = "id_rsa"
  subnet_id              = aws_subnet.secret_subnet.id
  vpc_security_group_ids = [aws_security_group.private_group.id, aws_security_group.ssh_from_testing.id]
  tags = {
    Name = "Web App"
  }
}

resource "aws_instance" "testing_instance" {
  ami                         = "ami-0c17cb8e234335014"
  instance_type               = var.instance_type
  key_name                    = "id_rsa"
  subnet_id                   = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssh_all.id]
  tags = {
    Name = "Testing"
  }
}

resource "aws_instance" "monitoring_instance" {
  ami                         = "ami-0c17cb8e234335014"
  instance_type               = var.instance_type
  key_name                    = "id_rsa"
  subnet_id                   = aws_subnet.main_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.monitoring.id, aws_security_group.ssh_from_testing.id]
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
  vpc_security_group_ids      = [aws_security_group.public_group.id, aws_security_group.ssh_from_testing.id]
  tags = {
    Name = "Nginx"
  }
}
