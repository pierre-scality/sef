{% from "scalitycloud/pkg.jinja" import pkglist with context %}

/tmp/pkglist:
  file.managed:
    - contents: |
        {{ pkglist }}

packages:
  pkg.installed:
    - names:
      {% for thispkg in pkglist %}
        - {{ thispkg }}
      {% endfor %}

permissive:
  selinux.mode

/etc/selinux/config:
  file.replace:
    - pattern: ^SELINUX=.*
    - repl: SELINUX=disabled


iptables:
  service.dead:
    - enable: False 
