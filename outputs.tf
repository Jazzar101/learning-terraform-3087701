output "instance_ami" {
  value = aws_instance.test_instance.ami
}

output "instance_arn" {
  value = aws_instance.test_instance.arn
}
