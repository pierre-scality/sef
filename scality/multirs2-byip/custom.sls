
include:
   - scality.rest-connector.registered
   - scality.req.python
#  - .log

{% from "scality/map.jinja" import scality with context %}

extend:
  scality-rest-connector:
    service.dead:
      - enable: False

xmlstarlet:
  pkg.installed

{% set prod_ip = salt['network.interface_ip'](scality.prod_iface) %}

# setup configuration repositories for multiple RS2 connectors

# the scality-rest-connector service needs to start at least once
# for all the files under confdb to be created

#cycle rest connector:
#  cmd.run:
#    - name: service scality-rest-connector start && sleep 5 && service scality-rest-connector stop && sleep 5 && ls /etc/scality-rest-connector/confdb/
#    - unless: test -d /etc/scality-rest-connector-1
#    - require:
#      - {{ scality.service_require }}: scality-rest-connector

cleanup default connector:
  cmd.run:
    - name: /usr/local/bin/sagentd-manageconf -c /etc/sagentd.yaml del {{ scality.ctor_name_prefix }}1
    - onlyif: grep -q {{ scality.ctor_name_prefix }}1 /etc/sagentd.yaml
    - onchange:
      - {{ scality.service_require }}: scality-rest-connector
    #- require_in:
    #  - service: scality-sagentd

{% set ctor_nbinstances = 2 %}

/etc/sysconfig/scality-multi-rs2:
  file.managed:
    - source: salt://scality/multirs2/scality-multi-rs2.sysconfig
    - template: jinja
    - context:
        nbinstances: {{ ctor_nbinstances }}
    - watch_in:
      - service: scality-multi-rs2

{% for ctor in range(1,ctor_nbinstances+1) %}

{% set ctor_index = loop.index %}
{% set ctor_name = '%s-rs2-%d' % (grains['id'],loop.index) %}
{% set ctor_ip = salt['network.interface_ip']('eth%d' % loop.index) %}
{% set port = 8184 %}
{% set ring = scality.metadata_ring %}

/etc/scality-rest-connector-{{ ctor_index }}/:
  cmd.run:
    - name: cp -r /etc/scality-rest-connector/ /etc/scality-rest-connector-{{ ctor_index }}
    - unless: test -d /etc/scality-rest-connector-{{ ctor_index }}
    - require:
      - {{ scality.service_require }}: scality-rest-connector
    - watch_in:
      - service: scality-multi-rs2

copy rest connector backup cron for {{ ctor_index }}:
  file.copy:
    - name: /etc/cron.daily/scality-rest-connector-{{ ctor_index }}-backup
    - source: /etc/cron.daily/scality-rest-connector-backup
    - require:
      - pkg: scality-rest-connector

configure rest connector backup cron for {{ ctor_index }}:
  file.replace:
    - name: /etc/cron.daily/scality-rest-connector-{{ ctor_index }}-backup
    - pattern: ^package=scality-rest-connector$
    - repl: package=scality-rest-connector-{{ ctor_index }}
    - require:
      - file: copy rest connector backup cron for {{ ctor_index }}

fix root directories in r0.0 config.xml {{ ctor_index }}:
  file.replace:
    - name: /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - pattern: etc/bizstore([^n])
    - repl: etc/scality-rest-connector-{{ ctor_index }}\1
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
    - watch_in:
      - service: scality-multi-rs2

fix root directories in r0.0 auth_group.xml {{ ctor_index }}:
  file.replace:
    - name: /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/auth_group.xml
    - pattern: etc/bizstore([^n])
    - repl: etc/scality-rest-connector-{{ ctor_index }}\1
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
    - watch_in:
      - service: scality-multi-rs2

/var/lib/scality-rest-connector-{{ ctor_index }}:
  file.directory:
    - user: root
    - dir_mode: 755
    - group: root


{% for subdir in ('local',) %}
fix node ipbind in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="ipbind" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="ipbind"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

fix admin ipbind in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="ipbind" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="ipbind"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2
{% endfor %}

{% for subdir in ('r0.0',) %}

fix node ipbind in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="ipbind" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="ipbind"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

fix admin ipbind in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="ipbind" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="ipbind"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

fix bwsrestserverip in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="msgstore_protocol_restapi"]/val[name="bwsrestserverip" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="msgstore_protocol_restapi"]/val[name="bwsrestserverip"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

fix bwsrestsslserverip in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="msgstore_protocol_restapi"]/val[name="bwsrestsslserverip" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="msgstore_protocol_restapi"]/val[name="bwsrestsslserverip"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

{% endfor %}

set password for connector {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="password" and text="{{ scality.credentials.internal_password }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="password"]/text' -v "{{ scality.credentials.internal_password }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

disable SSL on the 8184+ port {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="usessl" and text="0"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="usessl"]/text' -v 0 /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

set log dir for connector {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_core_logs"]/val[name="logsdir" and text="{{ scality.log.base_dir }}/scality-rest-connector-{{ ctor_index }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_core_logs"]/val[name="logsdir"]/text' -v {{ scality.log.base_dir }}/scality-rest-connector-{{ ctor_index }} /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

check-connector-listening-{{ ctor_index }}:
  scality_rest_connector.listening:
    - address: {{ ctor_ip }}
    - port: {{ port }}
    - require:
      - scality_server: register-{{ grains['id'] }}
      - service: scality-multi-rs2

declare-rest-connector-{{ ctor_index }}:
  scality_rest_connector.declared:
    - name: {{ ctor_name }}
    - address: {{ ctor_ip }}
    - port: {{ port }}
    - require:
      - {{ scality.service_require}}: scality-rest-connector
      - service: scality-multi-rs2
    - watch_in:
      - service: scality-sagentd
      - scality_server: register-{{grains['id']}}

{% if ring %}

add-rest-connector-{{ ctor_index }}:
  scality_rest_connector.added:
    - name: {{ ctor_name }}
    - ring: {{ ring }}
    - supervisor: {{ scality.supervisor_ip }}
    - login: {{ scality.credentials.internal_user }}
    - passwd: {{ scality.credentials.internal_password }}
    - require:
      - scality_rest_connector: check-connector-listening-{{ ctor_index }}
      - scality_rest_connector: declare-rest-connector-{{ ctor_index }}
      - pkg: python-scality
    #- onchanges_in:
    #  - cmd: generate ringsh config

{% endif %}

{% endfor %}

scality-multi-rs2:
  file.managed:
    - name: /etc/init.d/scality-multi-rs2
    - source: salt://scality/multirs2/scality-multi-rs2
    - mode: 0755
  service.running:
    - enable: True
    - require:
      - file: scality-multi-rs2
      - service: scality-rest-connector

