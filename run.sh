#!/bin/sh

terraform destroy --auto-approve
terraform plan
terraform apply --auto-approve
sleep 30s
ansible-playbook ./playbooks/deploy.yml
