---
  - name: Install Python3
    package:
      name:
        - "python3"
      state: present

  - name: Copy Test Files
    copy:
      src: ../files/run_tests.py
      dest: /home/ubuntu/run_tests.py
      owner: ubuntu
      force: true

  - name: Wait For API To Be Healthy
    uri:
      url: "http://${web_app_public_ip}/server/health"
      method: GET
      status_code: 200
    register: directus_health
    retries: 30
    delay: 5
    until: directus_health.status == 200

  - name: Run API Python Tests
    command:
      cmd: python3 run_tests.py
      chdir: /home/ubuntu/

  - name: Test Completion
    debug:
      msg: "API tests completed successfully!"
