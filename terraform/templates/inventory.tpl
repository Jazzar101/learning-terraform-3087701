[database]
database ansible_host=${database_ip} ansible_ssh_private_key_file="$SERVER_KEY" ansible_user=ubuntu ansible_ssh_common_args='-o ProxyJump=ubuntu@${testing_ip}'

[web_app]
app ansible_host=${web_app_ip} ansible_user=ubuntu ansible_ssh_common_args='-o ProxyJump=ubuntu@${testing_ip}'

[tests]
tests ansible_host=${testing_ip} ansible_user=ubuntu

[monitoring]
monitoring ansible_host=${monitoring_ip} ansible_user=ubuntu ansible_ssh_common_args='-o ProxyJump=ubuntu@${testing_ip}'

[nginx]
nginx ansible_host=${nginx_ip} ansible_user=ubuntu ansible_ssh_common_args='-o ProxyJump=ubuntu@${testing_ip}'
