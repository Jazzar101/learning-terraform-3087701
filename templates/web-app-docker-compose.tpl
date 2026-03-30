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
        volumes:
            - app_data:/var/lib/ghost/content
        healthcheck:
            test: ["CMD", "curl", "-f", "http://${web_app_public_ip}:2368"]
            interval: 30s
            timeout: 5s
            retries: 5

volumes:
    app_data:
