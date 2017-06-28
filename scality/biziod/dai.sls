{% set disk_nb = 4 %}
{% set diskstart = 1 %}
{% set reloc = "98" %}
{% set ring = "DATA" %}

{% for disk in range(diskstart,disk_nb+1) %}
{% if disk_nb > 9 and disk < 10%}
{% set current = 'disk0%d' % (loop.index) %}
{% else %}
{% set current = 'disk%d' % (loop.index) %}
{% endif %}

/etc/biziod/bizobj.{{ ring }}.{{ current }}:
  file.replace:
    - pattern: ^(dai_relocator_pass_time=.*)
    - append_if_not_found: True
    - not_found_content: dai_reloc_pass_time={{reloc}}
    - repl: dai_reloc_pass_time={{reloc}}

bizioctl -N {{ current }} -c bizobj_dai_relocator_pass_time -a {{ reloc }} bizobj://{{ ring }}:0 :
  cmd.run

bizioctl -N {{ current }} -c bizobj_show_conf_dynamic  bizobj://{{ring}}:0  | grep dai_reloc_pass_time :
  cmd.run

/etc/biziod/bizobj.{{ current }}:
  file.replace:
    - pattern: ^(dai_relocator_pass_time=.*)
    - append_if_not_found: True
    - not_found_content: dai_reloc_pass_time={{reloc}}
    - repl: dai_reloc_pass_time={{reloc}}
{% endfor %}

