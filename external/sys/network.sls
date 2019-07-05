{% for j in range(6) %}
{% set i = loop.index %}
{% set node = 'telstra-node%s' % (i) %}
{% if grains['nodename'] == node %} 
/tmp/{{ node }}:
  file.managed:
    - contents: 
      - {{ node }}
      - 10.10.64.1{{i}}
      - 10.10.65.1{{i}} 
eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - ipaddr: 10.10.64.1{{i}}
    - netmask: 255.255.255.0
    - gateway: 10.10.64.01
    - enable_ipv6: false

eth2:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - ipaddr: 10.10.65.1{{i}}
    - netmask: 255.255.255.0
    - gateway: 10.10.64.01
    - enable_ipv6: false
{% endif %}
{% endfor %}
