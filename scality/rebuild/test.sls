{% set ngx1 = salt['pkg.version']('scality-nginx-cache') %} 
{% set ngx2 = salt['pkg.version']('scality-nginx-cache-tamere') %} 
A{{ ngx2 }}:
  test.nop:
    - name: foo
{% if ngx1  %}
/tmp/q2:
  file.managed:
    - contents: 
      - {{ ngx1 }}
      - {{ ngx2 }}
{% endif %}
