output "instance_ami" {
  value = aws_instance.database_instance.ami
}

output "instance_arn" {
  value = aws_instance.database_instance.arn
}

output "database_public_ip" {
  value = aws_instance.database_instance.public_ip
}

output "web_app_public_ip" {
  value = aws_instance.web_app_instance.public_ip
}
