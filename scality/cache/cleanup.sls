nginx:
  service.dead

purge packages:
  pkg.removed:
    - pkgs:
      - nginx
      - scality-nginx-cache

include:
  - .sfused-nocache

start httpd:
  service.running:
    - name: httpd
    - reload: True
    - enable: True
