{% set ctdbv = salt['cmd.shell']('ctdb version').split('-')[0].split('.') %}

/tmp/ctdbversion:
  file.managed:
    - contents : 
      - {{ ctdbv }} 

{% if ctdbv[0] != 4 %}
{% if ctdbv[1] > 9 %}
include:
  - .init410
{% else %}
  - .init4
{% endif %} 
{% endif %} 

