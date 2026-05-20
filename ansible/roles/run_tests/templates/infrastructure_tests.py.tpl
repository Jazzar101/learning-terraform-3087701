import socket

class Test_Infrastructure:

    NGINX_IP = "${nginx_ip}"
    WEB_APP_IP = "${web_app_ip}"
    DATABASE_IP = "${database_ip}"
    MONITORING_IP = "${monitoring_ip}"

    def can_connect(self, host, port, timeout=3):
        """
        Return True if a TCP connection can be established.
        Return False if connection fails or times out.
        """
        try:
            with socket.create_connection((host, port), timeout=timeout):
                return True
        except (socket.timeout, OSError):
            return False

    def test_should_connect_to_instance_ssh(self):
        """
        SSH should be open on public instances and only accessible
        on database on the private subnet
        """
        port = 22
        instance_config = {
            "monitoring": {
                "host": self.MONITORING_IP,
                "result": True
            },
            "database": {
                "host": self.DATABASE_IP,
                "result": True
            },
            "web_app": {
                "host": self.WEB_APP_IP,
                "result": True
            },
            "nginx": {
                "host": self.NGINX_IP,
                "result": True
            }
        }

        for instance in instance_config.values():
            result = self.can_connect(instance.get("host"), port)
            assert result == instance.get("result")

    def test_should_connect_to_instance_mysql(self):
        """
        The database instance should accept and deny connections
        from specific instances only.
        """
        port = 3306
        instance_config = {
            "monitoring": {
                "host": self.MONITORING_IP,
                "result": False
            },
            "database": {
                "host": self.DATABASE_IP,
                "result": True
            },
            "web_app": {
                "host": self.WEB_APP_IP,
                "result": False
            },
            "nginx": {
                "host": self.NGINX_IP,
                "result": False
            }
        }
        for instance in instance_config.values():
            result = self.can_connect(instance.get("host"), port)
            assert result == instance.get("result")


    def test_should_connect_to_instance_node_metrics(self):
        """
        The node metrics port should not be connectable from any instance.
        """
        port = 9100
        instance_config = {
            "monitoring": {
                "host": self.MONITORING_IP,
                "result": False
            },
            "database": {
                "host": self.DATABASE_IP,
                "result": False
            },
            "web_app": {
                "host": self.WEB_APP_IP,
                "result": False
            },
            "nginx": {
                "host": self.NGINX_IP,
                "result": False
            }
        }
        for instance in instance_config.values():
            result = self.can_connect(instance.get("host"), port)
            assert result == instance.get("result")

    def test_should_connect_to_instance_docker_metrics(self):
        """
        The docker metrics port should not be connectable from any instance.
        """
        port = 8080
        instance_config = {
            "monitoring": {
                "host": self.MONITORING_IP,
                "result": False
            },
            "database": {
                "host": self.DATABASE_IP,
                "result": False
            },
            "web_app": {
                "host": self.WEB_APP_IP,
                "result": False
            },
            "nginx": {
                "host": self.NGINX_IP,
                "result": False
            }
        }
        for instance in instance_config.values():
            result = self.can_connect(instance.get("host"), port)
            assert result == instance.get("result")

    def test_should_connect_to_instance_web_traffic(self):
        """
        The docker metrics port should not be connectable from any instance.
        """
        port = 80
        instance_config = {
            "monitoring": {
                "host": self.MONITORING_IP,
                "result": False
            },
            "database": {
                "host": self.DATABASE_IP,
                "result": False
            },
            "web_app": {
                "host": self.WEB_APP_IP,
                "result": False
            },
            "nginx": {
                "host": self.NGINX_IP,
                "result": True
            }
        }
        for instance in instance_config.values():
            result = self.can_connect(instance.get("host"), port)
            assert result == instance.get("result")

    def test_should_connect_to_instance_monitoring_tools(self):
        """
        Test Grafana and Prometheus ports only open on monitoring instance.
        """
        port = 3000 # Grafana
        instance_config = {
            "monitoring": {
                "host": self.MONITORING_IP,
                "result": True
            },
            "database": {
                "host": self.DATABASE_IP,
                "result": False
            },
            "web_app": {
                "host": self.WEB_APP_IP,
                "result": False
            },
            "nginx": {
                "host": self.NGINX_IP,
                "result": False
            }
        }
        for instance in instance_config.values():
            result = self.can_connect(instance.get("host"), port)
            assert result == instance.get("result")

        port = 9090 # Prometheus
        for instance in instance_config.values():
            result = self.can_connect(instance.get("host"), port)
            assert result == instance.get("result")


