[database]
${database_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[web_app]
${web_app_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

