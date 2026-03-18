variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.micro"
}

variable "public_key" {
  description = "My public key"
  default     = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDhqu0YaJKFF7BTHIPKqX3iICTAFruOBrR5tiNmPqi8SlDr1BawAUdZEeIZimjUQJGUSc1rueq6ic17Xvxv/uKKukSA47JQ+inLSdG/lddYLC+9O0v1vorFopV3aby//V/NBpP+PyYt+WBwKiKNct+MrVQXbMYQ4JvxAcH+dNyc8q4p8vbOUxjIyBQHHdgdQhmQJQxxpWrXpiCsCkfyjb6w7E/1EtW75C5ieYcHn9IhTtSEMxnZ7JBvtkxNmQdlN1btIzmxIMI3mfYtcxCu0Oo+UvZruzktuD5Fchi0n/rzIUDJHonmjLOibLLWzybuEeN3KQhm5CRhlCQ8XZxk4Lcf/8+LjkeYCaDX4/YnyOjO4ZP4p6vvqbGGYFdUem2paCsrUJVNSDcT1YIgo2XUVKQ5akvBRIH/jfUymfyk8Qh6RKWHkrCJuOtyDt+bHGlKjhA6fsnuYvIlXntZauNF2iO2zO5WkTB6OUDjaV8ilSMAyZ11+CfI4uas6mbIUSqJFM9zUxPw5brs1HnExDgfsUq83Menzi12zK5VXqsA9coKFRWyUVlvQPcWCoQpTuKR7on9nCDyrufV/yWNwOyW1cigJCMYr928WYwpRCe8nB6b4cPEcGGuF75oiS9ez377pxQlM5DpmoqV5+mt72ucJ23ij2VKEFnASbLFyCyVGQOsAw== jared-g-d@hotmail.com
EOT
}
