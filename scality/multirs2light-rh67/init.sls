{% from "scality/map.jinja" import scality with context %}
{% set light = True %}
{% if grains['os_family'] == 'RedHat' %}
{% set osmajorrelease =  grains['osmajorrelease'] %} 
/tmp/osversion:
  file.managed:
    - contents:
      - {{ grains['os_family'] }} - {{ osmajorrelease }}
{% if osmajorrelease == '6' or osmajorrelease == '7' %}
include:
   - scality.req.python
   - scality.rest-connector.registered
{% if light == True %}
   - .light
{% endif %}
   - .custom{{ osmajorrelease }}
{% endif %}
{% endif %}
