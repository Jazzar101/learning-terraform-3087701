[database]
database ansible_host=${database_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[web_app]
app ansible_host=${web_app_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[tests]
tests ansible_host=${api_test_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa


