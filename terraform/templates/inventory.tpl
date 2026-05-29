[database]
${database_id} private_ip=${database_ip}

[web_app]
${web_app_id} private_ip=${web_app_ip}

[tests]
${testing_id} private_ip=${testing_ip}

[monitoring]
${monitoring_id} private_ip=${monitoring_ip}

[nginx]
${nginx_id} private_ip=${nginx_ip}

[all:vars]
ansible_user=ubuntu
ansible_connection=community.aws.aws_ssm
ansible_aws_ssm_region=eu-west-2
ansible_aws_ssm_bucket_name="infra-runner-bucket"
ansible_aws_ssm_timeout=120
ansible_aws_ssm_command_timeout=120
# ansible_aws_ssm_s3_addressing_style=virtual