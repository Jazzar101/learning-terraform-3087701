#!/bin/sh

terraform destroy --auto-approve
terraform plan
terraform apply --auto-approve

ansible-playbook ./playbooks/deploy.yml
