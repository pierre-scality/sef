{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 

{% set currentargs = salt['cmd.shell']('grep SFUSED_OPTIONS= /etc/sysconfig/scality-sfused').split('=')[1].split('"')[1] %}
{% set currentlist = currentargs.split(" ") %}

/tmp/a:
  file.managed:
    - contents:
      - args {{ currentargs }} 
      - args {{ currentlist }} 


{% set newop = currentargs ~ " -r" %}
Add -r to options:
  file.replace:
    - name: /etc/sysconfig/scality-sfused
    - pattern: SFUSED_OPTIONS=.*
    - repl: SFUSED_OPTIONS="{{newop}}"
    - unless: grep SFUSED_OPTIONS=  /etc/sysconfig/scality-sfused | grep -q   -- -r

{% if salt['file.is_link' ](ctdb.mountpoint) %}
stop sfused:
  service.dead:
    - name: scality-sfused

{{ ctdb.mountpoint }}:
  file.absent
{% endif %}
