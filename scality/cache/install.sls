
{% set cacherpm = "scality-nginx-cache-2-7.x86_64.rpm" %}

httpd:
  service.dead:
    - disable: True
  
save dewpoint fuse conf:
  file.copy:
    - source: /etc/dewpoint-sofs.js
    - name: /etc/dewpoint-sofs.js.before-scality-cache
    - force: false

save dewpoint conf:
  file.copy:
    - source: /etc/dewpoint.js
    - name: /etc/dewpoint.js.before-scality-cache
    - force: false

rpm scality cache:
  file.managed:
    - name: /tmp/{{ cacherpm}}
    - source: salt://scality/cache/{{ cacherpm}}
  cmd.run:
    - name: "rpm -hiv /tmp/{{ cacherpm}}"
    - unless: "rpm -q scality-nginx-cache"

include:
  - .sfused-cache

start nginx:
  service.running:
    - name: nginx
    - enable: true
    - watch:
      - file: /etc/nginx/conf.d/sca-lb.conf
  file.managed:
    - source: salt://scality/cache/sca-lb.conf
    - name: /etc/nginx/conf.d/sca-lb.conf 
