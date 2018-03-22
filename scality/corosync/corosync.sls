corosync:
  pkg.installed

/etc/default/corosync:
  file.managed:
    - contents:
      - START=yes

/var/log/corosync:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

enable corosync:
  service.enabled:
    - name: corosync

filecreate:
  file.managed:
    - name : /etc/corosync/corosync.conf
    - template: jinja
    - source: salt://scality/corosync/corosync.conf.tmpl

start corosync:
  service.running:
    - name: corosync
    - watch:
      - file: /etc/corosync/corosync.conf
