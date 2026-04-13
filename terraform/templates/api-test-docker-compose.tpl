services:
  api-tests:
    image: python:3.12
    container_name: ghost_api_tests
    volumes:
      - ./tests:/tests
    working_dir: /tests
    command: ["python", "run_tests.py"]
    environment:
      APP_URL: "http://${web_app_public_ip}"
