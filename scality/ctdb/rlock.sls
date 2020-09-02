#
# Module to configure ctdb_recovery_lock.yaml
#

{%- from "scality/map.jinja" import scality with context %}
{%- from "scality/zookeeper/cluster.sls" import client_hosts with context %}
{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 
{% set rlock = "/etc/ctdb/ctdb_recovery_lock.yaml" %}

configure ctdb_recovery_lock.yaml:
  file.managed:
    - name: {{ rlock }}
    - contents: |
        zk_hosts: {{ client_hosts | join(',') }}
        
        cluster: {{ ctdb.zkclustername }}
       
        # node_name default is `hostname`
        # node_name: test_node1


sernet-samba-ctdb:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{ rlock }}
