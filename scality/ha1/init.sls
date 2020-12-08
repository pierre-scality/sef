{%- if salt['file.file_exists' ]('/etc/scality/sagentd.yaml') %}
{%- set sagentd = "/etc/scality/sagentd.yaml" %}
{%- else %}
{%- set sagentd = "/etc/sagentd.yaml" %}
{%- endif %}

{{ sagentd }}:
  file.append:
   - source: salt://scality/ha1/sagentd.tmpl
   - template: jinja
   - require_in:
     - service: scality-sagentd
  service.running:
    - name: scality-sagentd
    - enable: True
    - watch:
      - file: {{ sagentd }}

