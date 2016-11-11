/etc/sysconfig/irqbalance:
  file.replace:
    - pattern: '#IRQBALANCE_ONESHOT='
    - repl: 'IRQBALANCE_ONESHOT=yes'

irqbalance:
  service.running:
    - watch:
      - file: /etc/sysconfig/irqbalance
