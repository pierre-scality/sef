#
# Module to configure and enable Virtual Server service
#

{% from "scality/map.jinja" import scality with context %}
{% from "scality/zookeeper/cluster.sls" import client_hosts with context %}

{% set net_ip = salt.network.ip_addrs(scality.svsd.net_iface)[0] %}
{% set zone = salt.pillar.get('scality:svsd:zone',[]) %}
{% set zones = [] %}

{% if "ROLE_CONN_NFS" in grains["roles"] %}
  {% do zones.append({'name': zone, 'rip': net_ip, 'pidfiles': [
    "/var/run/scality-sfused.pid",
  ]}) %}
{% endif %}

{% if "ROLE_CONN_CIFS" in grains["roles"] %}
  {% do zones.append({'name': zone, 'rip': net_ip, 'pidfiles': [
    "/var/run/scality-sfused.pid",
    "/var/run/samba/nmbd.pid",
    "/var/run/samba/smbd.pid",
  ]}) %}
{% endif %}

include:
  - .installed


configure svsd:
  file.serialize:
    - name: /etc/svsd.conf
    - formatter: JSON
    - dataset:
        general:
          zookeeper: {{ client_hosts | join(',') }}
        zones: {{ zones }}
    - require:
      - pkg: scality-svsd

{% if zones | length %}
enable svsd:
  service.running:
    - name: scality-svsd
    - enable: True
    - require:
      - pkg: scality-svsd
    - watch:
      - file: /etc/svsd.conf
{% else %}
disable svsd:
  service.dead:
    - name: scality-svsd
    - enable: False
{% endif %}

