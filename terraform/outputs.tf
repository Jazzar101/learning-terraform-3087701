output "instance_ami" {
  value = aws_instance.database_instance.ami
}

output "instance_arn" {
  value = aws_instance.database_instance.arn
}

output "database_private_ip" {
  value = aws_instance.database_instance.private_ip
}

output "web_app_private_ip" {
  value = aws_instance.web_app_instance.private_ip
}

output "testing_public_ip" {
  value = aws_instance.testing_instance.public_ip
}

output "monitoring_public_ip" {
  value = aws_instance.monitoring_instance.public_ip
}

