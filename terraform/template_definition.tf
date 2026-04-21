resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    database_private_ip  = aws_instance.database_instance.private_ip
    web_app_private_ip   = aws_instance.web_app_instance.private_ip
    api_test_public_ip   = aws_instance.api_test_instance.public_ip
    monitoring_public_ip = aws_instance.monitoring_instance.public_ip
    nginx_public_ip      = aws_instance.nginx_instance.public_ip
  })
  filename = "/etc/ansible/hosts"
}

resource "local_file" "compose" {
  content = templatefile("${path.module}/../roles/deploy_services/templates/web-app-docker-compose.yml.tpl", {
    database_private_ip = aws_instance.database_instance.private_ip
    web_app_private_ip  = aws_instance.web_app_instance.private_ip
  })
  filename = "../roles/deploy_services/files/app-docker-compose.yml"
}

resource "local_file" "api_tests_python" {
  content = templatefile("${path.module}/../roles/run_tests/templates/api_tests.py.tpl", {
    nginx_private_ip = aws_instance.nginx_instance.public_ip
  })
  filename = "../roles/run_tests/files/api_tests.py"
}

resource "local_file" "api_tests_tasks" {
  content = templatefile("${path.module}/../roles/run_tests/templates/main.yml.tpl", {
    nginx_private_ip = aws_instance.nginx_instance.private_ip
  })
  filename = "../roles/run_tests/tasks/main.yml"
}

resource "local_file" "nginx_config" {
  content = templatefile("${path.module}/../roles/configure_nginx/templates/nginx.conf.tpl", {
    web_app_private_ip = aws_instance.web_app_instance.private_ip
  })
  filename = "../roles/configure_nginx/files/nginx.conf"
}
