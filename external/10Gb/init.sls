{% from "scality/map.jinja" import scality with context %}

{% set iface_10Gb = salt['pillar.get']('scality:iface_10Gb', False) %}

{% if iface_10Gb %}
irqbalance:
  service.dead:
    - enable: False

/root/set_irq_affinity.sh:
  file.managed:
    - source: salt://network/10Gb/set_irq_affinity.sh
    - user: root
    - mode: 755
  cmd.run:
    - name: /root/set_irq_affinity.sh {{ iface_10Gb|join(' ') }}
    - require:
      - file: /root/set_irq_affinity.sh

{% for iface in iface_10Gb %}
scality-{{ iface }}-queuelen:
  cmd.run:
    - name: ifconfig {{ iface }} txqueuelen 10000
{% if grains['os_family'] == 'RedHat' %}
{{ iface }}:
  network.managed:
    - type: bond
    - mtu: 9000
    - mode: active-backup
{% endif %}

{% endfor %}


{% endif %}

net.ipv4.tcp_timestamps:
  sysctl:
    - present
    - value: 1

net.ipv4.tcp_sack :
  sysctl:
    - present
    - value: 1

net.ipv4.tcp_rmem:
  sysctl:
    - present
    - value: 4096 174760 16777216

net.ipv4.tcp_wmem:
  sysctl:
    - present
    - value: 4096 174760 16777216

net.core.netdev_max_backlog:
  sysctl:
    - present
    - value: 50000

net.core.somaxconn:
  sysctl:
    - present
    - value: 2048

net.core.rmem_max:
  sysctl:
    - present
    - value: 16777216

net.core.wmem_max:
  sysctl:
    - present
    - value: 16777216

