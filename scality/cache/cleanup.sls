nginx:
  service.dead

purge packages:
  pkg.removed:
    - pkgs:
      - nginx
      - scality-nginx-cache

restore dewpoint sofs conf:
  file.copy:
    - name: /etc/dewpoint-sofs.js
    - source: /etc/dewpoint-sofs.js.before-scality-cache
    - force: true

restore dewpoint conf:
  file.copy:
    - name: /etc/dewpoint.js
    - source: /etc/dewpoint.js.before-scality-cache
    - force: true

include:
  - .sfused-standard

start httpd:
  service.running:
    - name: httpd
    - reload: True
    - enable: True
