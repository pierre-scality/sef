
{% from "scality/map.jinja" import scality with context %}
{% from "scality/node/helpers.sls" import for_all_nodes with context %}

{% set nvp = {} %}
{% do nvp.update({1: (1, 3, 5, 7, 9, 11)}) %}
{% do nvp.update({2: (2, 4, 6, 8, 10, 12)}) %}
{%- for ssd, hdds in nvp.iteritems() %}
{%- for hdd in hdds %}
scality-ssd-{{hdd}}:
  cmd.run:
    - name: echo "nvp=/scality/ssd{{ ssd }}/bizobj-disk{{ hdd }}" >> /etc/biziod/bizobj.disk{{ hdd }}
    - unless: grep -q '^nvp=' /etc/biziod/bizobj.disk{{ hdd }}
    - require:
      - cmd: scality-node
    - require_in:
{%- call(node) for_all_nodes() %}
      - scality_node: add-{{ node.name }}
{%- endcall %}
  file.directory:
    - name: /scality/ssd{{ ssd }}/bizobj-disk{{ hdd }}
    - makedirs: True
{%- endfor %}
{%- endfor %}


