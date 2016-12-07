{% from "sysctl/sysctl.jinja" import sysctl with context %}


/tmp/sysctl.params:
  file.managed:
    - contents: |
        {{ sysctl }}

{% for param, value in sysctl.items() %}
sysctl-present-{{ param }}:
  sysctl.present: 
    - name: {{ param }}
    - value: {{ value }}
    - config: /etc/sysctl.d/50scality.conf

{% endfor %}
