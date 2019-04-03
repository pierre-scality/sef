stop sindexd:
  service.dead:
    - name: scality-sindexd 

remove sindexd {{ grains['host'] }}-sindexd:
  cmd.run:
    - name: /usr/local/bin/sagentd-manageconf -c /etc/sagentd.yaml del {{ grains['host'] }}-sindexd

scality-sagentd:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - cmd: remove sindexd {{ grains['host'] }}-sindexd
