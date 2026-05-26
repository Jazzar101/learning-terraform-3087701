[database]
database ansible_host=${database_id} ansible_user=ubuntu

[web_app]
app ansible_host=${web_app_id} ansible_user=ubuntu

[tests]
tests ansible_host=${testing_id} ansible_user=ubuntu

[monitoring]
monitoring ansible_host=${monitoring_id} ansible_user=ubuntu

[nginx]
nginx ansible_host=${nginx_id} ansible_user=ubuntu 
