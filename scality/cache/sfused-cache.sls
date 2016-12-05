scality-dewpoint-fcgi:
  service.running:
    - watch:
      - file: /etc/dewpoint-sofs.js
  file.managed:
    - source: salt://scality/cache/dewpoint-sofs.js.cache
    - name: /etc/dewpoint-sofs.js

  
