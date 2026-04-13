variable "database_instance_name" {
  description = "Name of the Database's EC2 instance name tag"
  type        = string
  default     = "database"
}

variable "web_app_instance_name" {
  description = "Name of the web app's EC2 instance name tag"
  type        = string
  default     = "web_app"
}

variable "api_test_instance_name" {
  description = "Name of the web app's EC2 instance name tag"
  type        = string
  default     = "Tests"
}

variable "instance_type" {
  description = "Type of EC2 instance to provision"
  type        = string
  default     = "t3.micro"
}

variable "main_subnet" {
  type = object({
    subnet_cidr = string
    name        = string
  })

  default = {
    subnet_cidr = "10.0.1.0/24"
    name        = "main_subnet"
  }
}


variable "main_key" {
  description = "My public key"
  default     = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCUyID24uOKhFubzMHHovQPkDs4LaaQFg1a+PUhFuIpCHkzrbci2USnnvZpuLflUhMySGDHyZ67xCyClPUPNT4J4yYWVFbaFKF8lMm5MGTdoUaFKwdJ1OiSvPc+omYM3hJ1k2iZPl/0tud69sNovSRh/1bB3jFPOJZ4cSaFk1GE4sLtWuk835z0MIWibqbC9bR6T11NDSVYKga+L+pCzSDm4qnj+nZF+v4B38ULFmJH4Dc+yy6l1R8qH4Dfvm49fpfsUz0SKNZ0y5telIFPMM0wqAmXN0AVqAp+nQZ5IUw/hRo8Jud9hBWmWW+HS4rKf00kjjmeYPS2kWC1/Ah/g4+kFW3kuL7cQViZBCYxt6lgcitMrHUzO1r9MW2g1NxZworP7T1Al0tFfxkypAoDZvTX49KgR/ap6hZRpnOoHKIz52ri6CehuGClJjR0OHHiQSoERTiEuwVfvn2ABxA3pWIGSdXWEY4WqO3ov1w/NtWWq7f3K2LnZT1jEPxkwaQA4LA/i7/BWtZWPerJ6KTI9N6oH4b/AgUju4uBi5EmOj/3O4QhwfZtqxyNPCwZUWvdWsokpQYinaMXYA0eiTYl24DDAzQEKXdsLCO8+TyLc0rl3jwwQK595USHnyQYcgZwHhq9bNzsXkcQL7zMoy6gNuIiJvybNiy8pbphWRMPp3/Q9Q==
EOT
}
