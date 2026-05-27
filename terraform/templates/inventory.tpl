[database]
${database_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm aws_ssm_region=eu-west-2

[web_app]
${web_app_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm aws_ssm_region=eu-west-2

[tests]
${testing_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm aws_ssm_region=eu-west-2

[monitoring]
${monitoring_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm aws_ssm_region=eu-west-2

[nginx]
${nginx_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm aws_ssm_region=eu-west-2
