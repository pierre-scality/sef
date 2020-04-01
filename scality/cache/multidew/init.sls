{% from "scality/map.jinja" import scality with context %}

{% set nb_instance = 4 %}
{% set myname = grains['nodename']  %}
{% set myip   = salt['network.interface_ip'](scality.data_iface) %}
{% set systemd_path = "/etc/systemd/system" %}

remove existing sagentd entry:
  cmd.run:
    - name: /usr/bin/sagentd-manageconf -c /etc/sagentd.yaml del {{ myname }}-dewpoint

{% for i in range(1,nb_instance+1) %}
create dewpoint sofs {{ i }}:
  file.managed:
    - source: salt://scality/cache/multidew/dewpoint.js.template
    - name: /etc/dewpoint-{{ i }}.js
    - template: jinja
    - user: root
    - group: root
    - defaults:
      instance: {{ i }}
      port: {{ 1038 + i }}

create rsyslog conf {{ i }}:
  file.managed:
    - source: salt://scality/cache/multidew/30-scality-dewpoint.conf
    - name: /etc/rsyslog.d/30-scality-dewpoint-{{ i }}.conf
    - template: jinja
    - user: root
    - group: root
    - defaults:
      instance: {{ i }}
{% endfor %}

restart syslog:
  service.running:
    - name: rsyslog
    - watch:
      - file: /etc/rsyslog.d/*

declare systemd multi instance: 
  file.managed:
    - name: {{ systemd_path }}/scality-dewpoint-fcgi@.service
    - source: salt://scality/cache/multidew/scality-dewpoint-fcgi.service
    - mode: 0755
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: {{ systemd_path }}/scality-dewpoint-fcgi@.service

{% for i in range(1,nb_instance+1) %}
Add dew {{ i }} in sagentd:
  cmd.run:
    - name: /usr/bin/sagentd-manageconf -c /etc/sagentd.yaml add {{ myname }}-dewpoint-{{ i }}  type=sfused  port={{ 7000 + i}} address={{ myip }}  path=/run/scality/connectors/dewpoint-{{ i}}
{% endfor %}                                                                                                

stop dew:
  service.dead:
    - name: scality-dewpoint-fcgi 

{% for this in range(nb_instance) %}
{% set inst = loop.index %}
start dew {{ inst }}:
  service.running:
    - name: scality-dewpoint-fcgi@{{inst}}
    - enable: true
{% endfor %}

replace nginx conf:
  file.managed:
    - name: /etc/nginx/conf.d/sca-lb.conf
    - source: salt://scality/cache/multidew/sca-lb.conf

restart nginx if conf changes:
  service.running:
    - name: nginx
    - watch:
      - file: /etc/nginx/conf.d/sca-lb.conf

configure log rotate:
  file.managed:
    - name: /etc/logrotate.d/scality-dewpoint
    - source: salt://scality/cache/multidew/scality-dewpoint.logrotate
