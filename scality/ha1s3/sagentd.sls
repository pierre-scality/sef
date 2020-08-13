{%- from "scality/ha1s3/ha1.jinja" import ha1 with context %}
{%- set s3_dir = ha1.s3_dir %}
{{s3_dir}}/scality-sproxyd/conf/sagentd.yaml:
  file.managed:
   - source: salt://scality/ha1s3/sagentd.tmpl
   - template: jinja
