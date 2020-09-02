{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 
{%- from "scality/map.jinja" import scality with context %}
{%- from "scality/zookeeper/cluster.sls" import client_hosts with context %}

{%- set rlock = "/etc/ctdb/ctdb_recovery_lock.yaml" %}
{%- set ctdbconf = "salt://scality/ctdb/ctdb.conf" %}

ensure sernet-samba-ctdb:
  pkg.installed:
    - name: sernet-samba-ctdb

{% if ctdb.norandomdir == True %}
include:
  - .norandomdir
{% endif %}

# fix what was done in previous versions
comment winbind:
  file.comment:
    - regex: CTDB_MANAGES_WINBIND.*
    - name: {{ ctdb.ctdbconf }}

Enable public ip:
  file.uncomment:
    - regex: CTDB_PUBLIC_ADDRESSES
    - name: {{ ctdb.ctdbconf }}

Enable node file:
  file.uncomment:
    - regex: CTDB_NODES
    - name: {{ ctdb.ctdbconf }}

Set cluster name:
  file.replace:
    - name: /etc/samba/smb.conf
    - pattern: "^netbios name.*"
    - repl : "netbios name = {{ ctdb.clustername }}"

Set cluster mode:
  file.line:
    - mode: ensure
    - content: clustering = yes
    - after: netbios name
    - name: /etc/samba/smb.conf

cp /etc/samba/smb.conf /tmp:
  cmd.run

Add fileid to vfs objects:
  cmd.run:
    - name: sed -i '/vfs objects/{s/fileid//;s/$/ fileid/}' /etc/samba/smb.conf

Add algorithm:
  file.line:
    - content: fileid:algorithm = fsname
    - mode: ensure
    - after: vfs objects
    - name: /etc/samba/smb.conf

/etc/ctdb/nodes:
  file.managed:
    - contents:
{%- for node in ctdb.ctdbmember %}
      - {{ node }}
{%- endfor %}

/etc/ctdb/public_addresses:
  file.managed:
    - contents:
{%- for vip in ctdb.ctdbvip %}
      - {{ vip }}
{%- endfor %}

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
      - file: {{ ctdb.ctdbconf }}
      - file: /etc/samba/smb.conf

{% for serv in ctdb.ctdb10services %}
disable {{ serv }}:
  service.dead:
    - enable: false
    - name : {{ serv }} 
{% endfor %}

{% for helper in ctdb.ctdb10helpers %} 
run helper {{ helper }}:
  cmd.run:
    - name: ctdb event script enable legacy {{ helper }}
{% endfor %}

