{% set epelkey = "RPM-GPG-KEY-EPEL-%s" % grains['osmajorrelease']  %}


include:
  - .python
  - scality.repo
  - scality.credentials


