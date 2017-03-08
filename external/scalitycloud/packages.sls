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

