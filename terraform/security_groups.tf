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
  cidr_blocks       = ["${aws_instance.web_app_instance.private_ip}/32", "${aws_instance.testing_instance.private_ip}/32"]
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

