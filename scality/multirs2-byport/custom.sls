
include:
  - .log

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

{% set ctor_instances = salt['pillar.get']('scality:rest-connector:instances', ()) %}

/etc/sysconfig/scality-multi-rs2:
  file.managed:
    - source: salt://scality/rest-connector/scality-multi-rs2.sysconfig
    - template: jinja
    - context:
        nbinstances: {{ ctor_instances|length }}
    - watch_in:
      - service: scality-multi-rs2

{% for ctor in ctor_instances %}

{% set ctor_index = ctor.get('index', loop.index) %}
{% set ctor_name = ctor.get('name', grains['id']) %}
{% set ip = ctor.get('ip', prod_ip) %}
{% set port = ctor.get('port', 8184) %}
{% set adminport = 4443 + port -8184 %}
{% set ring = ctor.get('ring', False) %}

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
    - pattern: ^package=scality-rest-connector
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

{% for subdir in ('r0.0',) %}

fix node portbind in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - name: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="portbind" and text="{{ port }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - unless: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="portbind"]/text' -v "{{ port }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

fix admin portbind in {{ subdir }} config.xml {{ ctor_index }}:
  cmd.run:
    - name: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="portbind" and text="{{ adminport }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - unless: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_interface_admin"]/val[name="portbind"]/text' -v "{{ adminport }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/{{ subdir }}/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

{% endfor %}

set password for connector {{ ctor_index }}:
  cmd.run:
    - name: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="password" and text="{{ scality.credentials.internal_password }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - unless: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="password"]/text' -v "{{ scality.credentials.internal_password }}" /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

disable SSL on the 8184+ port {{ ctor_index }}:
  cmd.run:
    - name: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="usessl" and text="0"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - unless: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_cluster_node"]/val[name="usessl"]/text' -v 0 /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

set log dir for connector {{ ctor_index }}:
  cmd.run:
    - name: xmlstarlet sel -t -c '/section [name="config"]/branch [name="ov_core_logs"]/val[name="logsdir" and text="{{ scality.log.base_dir }}/scality-rest-connector-{{ ctor_index }}"]' /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - unless: xmlstarlet ed -P --inplace -u '/section [name="config"]/branch [name="ov_core_logs"]/val[name="logsdir"]/text' -v {{ scality.log.base_dir }}/scality-rest-connector-{{ ctor_index }} /etc/scality-rest-connector-{{ ctor_index }}/confdb/r0.0/config.xml
    - require:
      - cmd: /etc/scality-rest-connector-{{ ctor_index }}/
      - pkg: xmlstarlet
    - watch_in:
      - service: scality-multi-rs2

check-connector-listening-{{ ctor_index }}:
  scality_rest_connector.listening:
    - address: {{ prod_ip }}
    - port: {{ port }}
    - require:
      - scality_server: register-{{ grains['id'] }}
      - service: scality-multi-rs2

declare-rest-connector-{{ ctor_index }}:
  scality_rest_connector.declared:
    - name: {{ ctor_name }}
    - address: {{ prod_ip }}
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
    - onchanges_in:
      - cmd: generate ringsh config

config-rest-connector-{{ ctor_index }}:
  scality_rest_connector.configured:
    - name: {{ ctor_name }}
    - ring: {{ ring }}
    - supervisor: {{ scality.supervisor_ip }}
    - login: {{ scality.credentials.internal_user }}
    - passwd: {{ scality.credentials.internal_password }}
    - defaults:
        msgstore_protocol_restapi:
          bwsdrvdata: arc
          chordsplitsizetrigger: 4000000
          chordsplitsizeblock: 2000000
          bwssplitsizetrigger: 4000000
          bwssplitsizeblock: 2000000
{%- if ring == 'Ring_FR_MD' %}
          bwsdrvdataopts: sproxyd_srv=10.70.61.1:81,10.70.61.2:81,10.70.61.3:81,10.70.61.4:81,10.70.61.5:81,10.70.61.6:81;sproxyd_uri_arc=/proxy/arc-fr-d;sproxyd_uri_chord=/proxy/chord-fr-d
{%- endif %}
{%- if ring == 'Ring_Corp_MD' %}
          bwsdrvdataopts: sproxyd_srv=10.70.61.1:81,10.70.61.2:81,10.70.61.3:81,10.70.61.4:81,10.70.61.5:81,10.70.61.6:81;sproxyd_uri_arc=/proxy/arc-corp-d;sproxyd_uri_chord=/proxy/chord-corp-d;sproxyd_blacklist_time=30
{%- endif %}
        msgstore_storage_chordbucket:
          bwsdbmesamaincos: 4
          bwsdbmesacos: 2
          bwsdbmesahost: 127.0.0.1:81
{%- if ring == 'Ring_FR_MD' %}
          bwsdbmesauri: /sindexd-fr.fcgi
{%- endif %}
{%- if ring == 'Ring_Corp_MD' %}
          bwsdbmesauri: /sindexd-corp.fcgi
{%- endif %}
        msgstore_storage_chunkapi:
          chunkapiupdatelistsize: 1024
        msgstore_supervisor_bizstoreserver:
          bsserverctmplname: {{ ctor_name }}.tpl
        ov_core_logs:
          logsdir: {{ scality.log.base_dir }}/scality-rest-connector-{{ ctor_index }}
          logsoccurrences: 20
          logsmaxsize: 512
        ov_protocol_netscript:
          connect timeout: 30
          socket timeout: 300
    - require:
      - scality_rest_connector: add-rest-connector-{{ ctor_index }}

{% endif %}

{% endfor %}

scality-multi-rs2:
  file.managed:
    - name: /etc/init.d/scality-multi-rs2
    - source: salt://scality/rest-connector/scality-multi-rs2
    - mode: 0755
  service.running:
    - enable: True
    - require:
      - file: scality-multi-rs2
      - service: scality-rest-connector

