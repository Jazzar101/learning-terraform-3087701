---
  - name: Install Python3
    package:
      name:
        - "python3"
        - "python3-pip"
        - "python3-venv"
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
      - src: ../files/infrastructure_tests.py
        dest: /home/ubuntu/infrastructure_tests.py

  - name: Wait For API To Be Healthy
    uri:
      url: "http://${nginx_private_ip}/server/health"
      method: GET
      status_code: 200
    register: directus_health
    retries: 30
    delay: 5
    until: directus_health.status == 200

  - name: Create Python3 Venv
    command:
      cmd: "python3 -m venv venv"
      chdir: /home/ubuntu/

  - name: Install dependencies
    pip:
      name:
        - pytest
        - mysql-connector-python
        - requests
      virtualenv: /home/ubuntu/venv

  - name: Run API Python Tests
    command:
      cmd: /home/ubuntu/venv/bin/python api_tests.py
      chdir: /home/ubuntu/

  - name: Run Database Python Tests
    command:
      cmd: sudo /home/ubuntu/venv/bin/python -m pytest db_tests.py
      chdir: /home/ubuntu/
    register: db_test_results

  - name: Output DB Test Results
    debug:
      var: db_test_results.stdout

  - name: Run Infrastructure Tests
    command:
      cmd: sudo /home/ubuntu/venv/bin/python -m pytest infrastructure_tests.py
      chdir: /home/ubuntu/
    register: infra_test_results

  - name: Output Infrastructure Test Results
    debug:
      var: infra_test_results.stdout

  - name: Test Completion
    debug:
      msg: "All tests completed successfully!"
