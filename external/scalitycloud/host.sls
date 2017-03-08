
{% if grains['host'] %}
/etc/sysconfig/network:
  file.append:
    - text: HOSTNAME={{grains['host']}}

/etc/hostname:
  file.managed:
    - contents: {{grains['host']}}
{% endif %}
