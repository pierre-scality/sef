{%- from "scality/ctdb/ctdb.jinja" import ctdb with context %} 

{%- set ctdbconf = "salt://scality/ctdb/ctdb.conf" %}

sernet-samba-ctdb:
  pkg.installed

{%- if ctdb.security == "ads" %}
Uncomment winbind:
  file.uncomment:
    - regex: CTDB_MANAGES_WINBIND
    - name: {{ ctdb.ctdbconf }}
Ensure yes setting:
  file.replace:
    - pattern: CTDB_MANAGES_WINBIND.*
    - repl: CTDB_MANAGES_WINBIND=yes
    - name: {{ ctdb.ctdbconf }}
{%- else %}
  file.comment:
    - regex: CTDB_MANAGES_WINBIND.*
    - name: {{ ctdb.ctdbconf }}
{%- endif %}

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
    - enable: true
    - full_restart: true
    - watch:
      - file: {{ ctdb.ctdbconf }}
      - file: /etc/samba/smb.conf
