server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://${web_app_private_ip}:8055;

        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
