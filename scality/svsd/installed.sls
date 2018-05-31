#
# Module to install the Virtual Server packages
#

{% from "scality/map.jinja" import scality with context %}
{% from "scality/macro.sls" import pkg_install_scality with context %}

include:
  - scality.repo


install svsd:
  {{ pkg_install_scality() }}
    - name: scality-svsd

