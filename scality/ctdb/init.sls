{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 

{%- set ctdbconf = "salt://scality/ctdb/ctdb.conf" %}

sernet-samba-ctdb:
  pkg.installed

{%- if ctdb.security == "ads" %}
Uncomment winbind:
  file.uncomment:
    - regex: CTDB_MANAGES_WINBIND
    - name: /etc/sysconfig/ctdb
Ensure yes setting:
  file.replace:
    - pattern: CTDB_MANAGES_WINBIND.*
    - repl: CTDB_MANAGES_WINBIND=yes
    - name: /etc/sysconfig/ctdb
{%- else %}
  file.comment:
    - regex: CTDB_MANAGES_WINBIND.*
    - name: /etc/sysconfig/ctdb
{%- endif %}

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
  cmd.run:
    - name: sed -i '/vfs objects/ a fileid:algorithm = fsname' /etc/samba/smb.conf
    - content: fileid:algorithm = fsname

/etc/ctdb/nodes:
  file.managed:
    - source: salt://scality/ctdb/files/nodes

/etc/ctdb/public_addresses:
  file.managed:
    - source: salt://scality/ctdb/files/public_addresses

/etc/ctdb/events.d/09.sfused:
  file.managed:
    - source: salt://scality/ctdb/files/09.sfused

{% for p in ctdb.smbservices %}
disable samba {{ p }}:
  service.dead:
    - name: {{ p }}
    - enable: false
{% endfor %}

restart sernet-samba-ctdb:
  service.running:
    - name: sernet-samba-ctdb
    - reload: true
    - enable: true
    - watch:
      - file: /etc/sysconfig/ctdb
      - file: /etc/samba/smb.conf
