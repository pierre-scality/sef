corosync:
  pkg.installed

filecreate:
  file.managed:
    - name : /etc/corosync/corosync.conf
    - template: jinja
    - source: salt://scality/corosync/corosync.conf.tmpl

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

start corosync:
  service.running:
    - name: corosync
