---
services:
    app:
        image: ghost:latest
        container_name: app
        restart: always
        ports:
            - "2368:2368"
        environment:
            database__client: "mysql"
            database__connection__host: "${database_public_ip}"
            database__connection__user: "user"
            database__connection__password: "password123"
            database__connection__database: "ghost"
            url: "http://${web_app_public_ip}"
        volumes:
            - app_data:/var/lib/ghost/content
        healthcheck:
            test: ["CMD", "curl", "-f", "http://${web_app_public_ip}:2368"]
            interval: 30s
            timeout: 5s
            retries: 5
    
    nginx:
        image: nginx:latest
        container_name: nginx
        restart: always
        ports:
            - "80:80"
        volumes:
            - /home/ubuntu/nginx.conf:/etc/nginx/conf.d/default.conf:ro
        depends_on:
            - app

volumes:
    app_data:
