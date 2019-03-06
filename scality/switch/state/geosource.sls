
uwsgi:
  service.running:
    - enable: true

cleanup scality-sfullsyncd-target:
  service.dead:
    - name: scality-sfullsyncd-target
    - enable: false

{% set srv = grains['host'].lower() %}
remove fullsyncd-target sagentd entry:
  cmd.run:
    - name: scality-sagentd-config -c /etc/sagentd.yaml remove -n {{ srv }}-sfullsync01
    - onlyif: grep -q {{ srv }}-sfullsync01 /etc/sagentd.yaml

scality-sagentd:
  service.running:
    - restart: true
    - watch:
      - cmd: remove fullsyncd-target sagentd entry

/var/tmp/scality-geoflag:
  file.managed:
    - contents:
      - roles scality geosync source daemon

