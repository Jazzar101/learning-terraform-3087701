[database]
${database_id}

[web_app]
${web_app_id}

[tests]
${testing_id}

[monitoring]
${monitoring_id}

[nginx]
${nginx_id}  

[all:vars]
ansible_user=ubuntu
ansible_connection=community.aws.aws_ssm
ansible_aws_ssm_region=eu-west-2
ansible_aws_ssm_bucket_name="infra-runner-bucket"
