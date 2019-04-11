{% from "scality/map.jinja" import scality with context %}
{% if grains['os_family'] == 'RedHat' %}
{% set osmajorrelease =  grains['osmajorrelease'] %} 
/tmp/test:
  file.managed:
    - contents:
      - {{ grains['os_family'] }}
      - {{ osmajorrelease }}
{% if osmajorrelease == '6' or osmajorrelease == '7' %}
include:
   - scality.rest-connector.registered
   - scality.req.python
   - .custom{{ osmajorrelease }}
{% endif %}
{% endif %}
