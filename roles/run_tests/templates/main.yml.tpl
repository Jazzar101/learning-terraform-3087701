---
  - name: Install Python3
    package:
      name:
        - "python3"
      state: present

  - name: Copy Test Files
    copy:
      src: "{{ item.src }}"
      dest: "{{ item.dest }}"
      owner: ubuntu
      force: true
    loop:
      - src: ../files/api_tests.py
        dest: /home/ubuntu/api_tests.py
      - src: ../files/db_tests.py
        dest: /home/ubuntu/db_tests.py

  - name: Wait For API To Be Healthy
    uri:
      url: "http://${nginx_private_ip}/server/health"
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

  - name: Run Database Python Tests
    command:
      cmd: python3 db_tests.py
      chdir: /home/ubuntu/

  - name: Test Completion
    debug:
      msg: "API tests completed successfully!"
