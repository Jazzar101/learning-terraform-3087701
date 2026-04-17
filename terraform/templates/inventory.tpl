[database]
database ansible_host=${database_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_common_args='-o ProxyJump=ubuntu@${nginx_public_ip}'

[web_app]
app ansible_host=${web_app_private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_common_args='-o ProxyJump=ubuntu@${nginx_public_ip}'

[tests]
tests ansible_host=${api_test_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[monitoring]
monitoring ansible_host=${monitoring_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

[nginx]
nginx ansible_host=${nginx_public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
