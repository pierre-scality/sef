include:
  - .corosync

/etc/sfused.conf.nodlm:
  file.copy:
    - source: /etc/sfused.conf

/etc/dlm/:
  file.directory

/var/log/dlm_controld/:
  file.directory

/etc/dlm/dlm.conf:
  file.managed:
    - contents:
      - enable_fencing=0

dlm:
  pkg:
   - installed
  service.running:
   - enable: True

scality-sfused:
  service.running:
    - watch:
      - file: /etc/sfused.conf
  file.serialize:
    - name: /etc/sfused.conf
    - dataset:
        general: 
          fs_batch: true
        dlm:
          enable: true
    - formatter: json
    - create: false
    - merge_if_exists: true 

scality-nasdk-tools:
  pkg.installed
