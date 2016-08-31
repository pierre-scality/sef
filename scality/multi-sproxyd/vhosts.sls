
{% from "scality/map.jinja" import scality with context %}

/etc/httpd/conf.d/multiple-hosts.conf:
  file.managed:
    - source: salt://scality/sproxyd/vhosts.tmpl
    - template: jinja
    - watch_in:
      - service: restart-scality-httpd

restart-scality-httpd:
  cmd.run:
    - name: service httpd restart

