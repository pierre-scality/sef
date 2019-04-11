{% from "scality/map.jinja" import scality with context %}
{% from "scality/node/helpers.sls" import for_all_nodes with context %}

{# There is only 1 ring for nvp #}
{% set ring = scality.rings.split(',')[0] %}

{% set disknb = 4 %}
{% set nba=1 %}

{% set nvp = {} %}
{% set dsklst = [] %}
{% set ssdcount = 2 %}
{% set hddperssd = 2 %}
{% set current = 1 %}

{% for s in range(1,ssdcount+1) %}
{% set l0 = loop %}
{% for d in range(1,hddperssd+1) %}
{% set current = l0.index0*hddperssd+d %}
/tmp/toto-{{s}}-{{current}}:
  file.touch
{% endfor %}
{% do nvp.update({s:dsklst}) %}
{% set current = current+hddperssd %}
{% endfor %}

{# {% do nvp.update({1: (1, 2)}) %} #}
{# {% do nvp.update({2: (3, 4)}) %} #}
{% do nvp.update({1: (1, 2)}) %}
{% do nvp.update({2: (3, 4)}) %}

/tmp/debug:
  file.managed:
    - content: nvp

stop-node:
  service.dead:
    - name : scality-node

{%- for ssd, hdds in nvp.iteritems() %}
{%- for hdd in hdds %}
scality-{{ssd}}-{{hdd}}:
  cmd.run:
    - name: echo "nvp=/scality/ssd{{ ssd }}/bizobj-disk{{ hdd }}" >> /etc/biziod/bizobj.disk{{ hdd }}
    - unless: grep -q '^nvp=' /etc/biziod/bizobj.disk{{ hdd }}
  file.directory:
    - name: /scality/ssd{{ ssd }}/bizobj-disk{{ hdd }}/{{ ring }}/0/
    - makedirs: True
scality-{{ssd}}-{{hdd}}-{{ ring }}:
  cmd.run:
    - name: echo "nvp=/scality/ssd{{ ssd }}/bizobj-disk{{ hdd }}" >> /etc/biziod/bizobj.{{ ring }}.disk{{ hdd }}
    - unless: grep -q '^nvp=' /etc/biziod/bizobj.{{ ring }}.disk{{ hdd }}
scality-nba-{{hdd}}:
  cmd.run:
    - name: echo "nba={{ nba }}" >> /etc/biziod/bizobj.disk{{ hdd }}
    - unless: grep -qi '^nba=' /etc/biziod/bizobj.disk{{ hdd }}
scality-nba-{{ ring }}-{{hdd}}:
  cmd.run:
    - name: echo "nba={{ nba }}" >> /etc/biziod/bizobj.{{ ring }}.disk{{ hdd }}
    - unless: grep -qi '^nba=' /etc/biziod/bizobj.{{ ring }}.disk{{ hdd }}
rename-bizobj-{{hdd}}:
  file.rename:
    - source: /scality/disk{{ hdd }}/{{ ring }}/0/bizobj.bin
    - name: /scality/disk{{ hdd }}/{{ ring }}/0/bizobj.bin.dispose
{%- endfor %}
{%- endfor %}

start-node:
  service.running:
    - name : scality-node

