[database]
ansible_host=${database_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm ansible_aws_ssm_region=eu-west-2 aws_ssm_bucket_name="infra-runner-bucket" aws_ssm_bucket_prefix="ansible-ssm-files"

[web_app]
${web_app_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm ansible_aws_ssm_region=eu-west-2

[tests]
${testing_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm ansible_aws_ssm_region=eu-west-2

[monitoring]
${monitoring_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm ansible_aws_ssm_region=eu-west-2

[nginx]
${nginx_id} ansible_user=ubuntu ansible_connection=community.aws.aws_ssm ansible_aws_ssm_region=eu-west-2
