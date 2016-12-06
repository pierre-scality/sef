dewpoint file:
  file.managed:
    - source: salt://scality/cache/dewpoint.js.nocache
    - name: /etc/dewpoint.js

scality-dewpoint-fcgi:
  service.running:
    - watch:
      - file: /etc/dewpoint-sofs.js
  file.managed:
    - source: salt://scality/cache/dewpoint-sofs.js.nocache
    - name: /etc/dewpoint-sofs.js

  
