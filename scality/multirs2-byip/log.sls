

{% from "scality/map.jinja" import scality with context %}

include:
  - scality.req.rsyslog

rsyslog:
  pkg:
    - installed
  service.running:
    - enable: True
    - watch:
      - file: /etc/rsyslog.conf
  file.managed:
    - name: /etc/rsyslog.conf
    - user: root
    - group: root
    - mode: 0644
    - source : salt://scality/rest-connector/rsyslog.conf

configure logrotate:
  pkg.installed:
    - name: logrotate
  file.managed:
    - name: /etc/logrotate.d/scality
    - source: salt://scality/rest-connector/scality.logrotate

