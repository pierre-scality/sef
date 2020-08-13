update federation:
  file.append:
    - name: /srv/scality/s3/s3-offline/federation/roles/run-sproxyd/templates/supervisord.conf.j2
    - source: salt://scality/ha1s3/supervisord.conf.j2
