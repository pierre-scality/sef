
set fuse configuration:
  file.serialize:
    - name: /etc/dewpoint-sofs.js
    - dataset:
        transport:
          mountpoint: "/ring/fs"
        general:
          geosync: true
          geosync_prog: "/usr/bin/sfullsyncaccept"
          geosync_args: "/usr/bin/sfullsyncaccept --v3 --user scality -w /journal $FILE"
          geosync_interval: 10
          geosync_run_cmd: true
          geosync_tmp_dir: "/var/tmp/geosync"
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion


scality-dewpoint-fcgi.service:
  service.running:
    - watch:
      - file: /etc/dewpoint-sofs.js

{% for service in ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd'] %}
start samba {{ service }}:
  service.running:
    - name: {{ service }}
    - enable: true
    - watch:
      - file: /etc/dewpoint-sofs.js
{% endfor %}


/var/tmp/scality-geoflag:
  file.managed:
    - contents:
      - roles scality source connector

