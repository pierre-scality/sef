{% set ifname = 'fe0' %}
{% set ip = grains['ip_interfaces'][ifname][0] %}
{% set srv = grains['host'].lower() %}

add entry sagentd:
  cmd.run:
    - name: scality-sagentd-config -c /etc/sagentd.yaml add -n {{ srv }}-sfullsync01 -t sfullsyncd-target -H {{ ip }} -p 8381
    - unless: grep -q {{ srv }}-sfullsync01 /etc/sagentd.yaml

scality-sagentd:
  service.running:
    - restart: true
    - watch:
      - cmd: add entry sagentd

stop scality-sfullsyncd-source:
  service.dead:
    - name: uwsgi
    - enable: false

enable scality-sfullsyncd-target:
  service.running:
    - name: scality-sfullsyncd-target
    - enable: true

/var/tmp/scality-geoflag:
  file.managed:
    - contents:
      - roles scality geosync target daemon

