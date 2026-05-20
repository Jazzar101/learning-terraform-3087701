resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    database_ip   = aws_instance.database_instance.private_ip
    web_app_ip    = aws_instance.web_app_instance.private_ip
    testing_ip    = aws_instance.testing_instance.public_ip
    monitoring_ip = aws_instance.monitoring_instance.private_ip
    nginx_ip      = aws_instance.nginx_instance.private_ip
  })
  filename = "${path.module}/../ansible/hosts"
}

resource "local_file" "env_file" {
  content = templatefile("${path.module}/templates/set_env.sh.tpl", {
    database_ip   = aws_instance.database_instance.private_ip
    web_app_ip    = aws_instance.web_app_instance.private_ip
    testing_ip    = aws_instance.testing_instance.public_ip
    monitoring_ip = aws_instance.monitoring_instance.private_ip
    nginx_ip      = aws_instance.nginx_instance.private_ip
  })
  filename = "${path.module}/../set_env.sh"
}

resource "local_file" "compose" {
  content = templatefile("${path.module}/../ansible/roles/deploy_services/templates/web-app-docker-compose.yml.tpl", {
    database_private_ip = aws_instance.database_instance.private_ip
    web_app_private_ip  = aws_instance.web_app_instance.private_ip
  })
  filename = "${path.module}/../ansible/roles/deploy_services/files/app-docker-compose.yml"
}

resource "local_file" "api_tests_python" {
  content = templatefile("${path.module}/../ansible/roles/run_tests/templates/api_tests.py.tpl", {
    nginx_private_ip = aws_instance.nginx_instance.public_ip
  })
  filename = "${path.module}/../ansible/roles/run_tests/files/api_tests.py"
}

resource "local_file" "db_tests_python" {
  content = templatefile("${path.module}/../ansible/roles/run_tests/templates/db_tests.py.tpl", {
    database_private_ip = aws_instance.database_instance.private_ip
  })
  filename = "${path.module}/../ansible/roles/run_tests/files/db_tests.py"
}

resource "local_file" "infrastructure_tests" {
  content = templatefile("${path.module}/../ansible/roles/run_tests/templates/infrastructure_tests.py.tpl", {
    database_ip   = aws_instance.database_instance.private_ip
    web_app_ip    = aws_instance.web_app_instance.private_ip
    monitoring_ip = aws_instance.monitoring_instance.private_ip
    nginx_ip      = aws_instance.nginx_instance.private_ip
  })
  filename = "${path.module}/../ansible/roles/run_tests/files/infrastructure_tests.py"
}

resource "local_file" "testing_tasks" {
  content = templatefile("${path.module}/../roles/run_tests/templates/main.yml.tpl", {
    nginx_private_ip = aws_instance.nginx_instance.private_ip
  })
  filename = "${path.module}/../ansible/roles/run_tests/tasks/main.yml"
}

resource "local_file" "nginx_config" {
  content = templatefile("${path.module}/../ansible/roles/configure_nginx/templates/nginx.conf.tpl", {
    web_app_private_ip = aws_instance.web_app_instance.private_ip
  })
  filename = "../ansible/roles/configure_nginx/files/nginx.conf"
}

resource "local_file" "promtail_config" {
  content = templatefile("${path.module}/../ansible/roles/configure_nginx/templates/promtail-config.yml.tpl", {
    monitoring_ip = aws_instance.monitoring_instance.private_ip
  })
  filename = "${path.module}/../ansible/roles/configure_nginx/files/promtail-config.yml"
}

