{% from "scality/map.jinja" import scality with context %}

extend:
  scality-rest-connector:
    service.dead:
      - enable: False

xmlstarlet:
  pkg.installed

{% set prod_ip = salt['network.interface_ip'](scality.prod_iface) %}

cleanup default connector:
  cmd.run:
    - name: /usr/local/bin/sagentd-manageconf -c /etc/sagentd.yaml del {{ scality.ctor_name_prefix }}1
    - onlyif: grep -q {{ scality.ctor_name_prefix }}1 /etc/sagentd.yaml
    - onchange:
      - {{ scality.service_require }}: scality-rest-connector
    #- require_in:
    #  - service: scality-sagentd


declare systemd multi instance:
  file.managed:
    - name: /usr/lib/systemd/system/scality-rest-connector@.service
    - source: salt://scality/multirs2/scality-multi-rs2.systemd
    - mode: 0755

{% set ctor_nbinstances = 2 %}
{% for ctor in range(ctor_nbinstances) %}

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
      - service: scality-rest-connector@{{ ctor_index }}

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
      - service: scality-rest-connector@{{ ctor_index }}

fix root directories in r0.0 auth_group.xml {{ ctor_index }}:
  file.replace:
    - name: /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/auth_group.xml
    - pattern: etc/bizstore([^n])
    - repl: etc/scality-rest-connector-{{ ctor_index }}\1
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
    - watch_in:
      - service: scality-rest-connector@{{ ctor_index }}

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
      - service: scality-rest-connector@{{ ctor_index }}

fix admin ipbind in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="ipbind" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="ipbind"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-rest-connector@{{ ctor_index }}
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
      - service: scality-rest-connector@{{ ctor_index }}

fix admin ipbind in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="ipbind" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="ipbind"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-rest-connector@{{ ctor_index }}

# Fix
fix bwsrestserverip in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="msgstore_protocol_restapi"]/val[name="bwsrestserverip" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="msgstore_protocol_restapi"]/val[name="bwsrestserverip"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-rest-connector@{{ ctor_index }}

fix bwsrestsslserverip in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="msgstore_protocol_restapi"]/val[name="bwsrestsslserverip" and text="{{ ctor_ip }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="msgstore_protocol_restapi"]/val[name="bwsrestsslserverip"]/text' -v "{{ ctor_ip }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-rest-connector@{{ ctor_index }}

{% endfor %}

set password for connector {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="password" and text="{{ scality.credentials.internal_password }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="password"]/text' -v "{{ scality.credentials.internal_password }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-rest-connector@{{ ctor_index }}

disable SSL on the 8184+ port {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="usessl" and text="0"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="usessl"]/text' -v 0 /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-rest-connector@{{ ctor_index }}

set log dir for connector {{ ctor_index }}:
  cmd.run:
    - unless: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_core_logs"]/val[name="logsdir" and text="{{ scality.log.base_dir }}/scality-rest-connector-{{ ctor_index }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - name: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_core_logs"]/val[name="logsdir"]/text' -v {{ scality.log.base_dir }}/scality-rest-connector-{{ ctor_index }} /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-rest-connector@{{ ctor_index }}

check-connector-listening-{{ ctor_index }}:
  scality_rest_connector.listening:
    - address: {{ ctor_ip }}
    - port: {{ port }}
    - require:
      - scality_server: register-{{ grains['id'] }}
      - service: scality-rest-connector@{{ ctor_index }}

declare-rest-connector-{{ ctor_index }}:
  scality_rest_connector.declared:
    - name: {{ ctor_name }}
    - address: {{ ctor_ip }}
    - port: {{ port }}
    - require:
      - {{ scality.service_require}}: scality-rest-connector
      - service: scality-rest-connector@{{ ctor_index }}
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


{% for inst in range(ctor_nbinstances) %}
{% set inst_index = loop.index %}
scality-rest-connector@{{ inst_index }}:
  service.running:
    - enable: True
    - restart: True
{% endfor %}

