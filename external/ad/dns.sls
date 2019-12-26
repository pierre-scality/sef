{% from "ad/ad.jinja" import ad with context%} 
{% set ownip = grains['ip4_interfaces']['eth0'][0] %}

/etc/resolv.conf:
  file.managed:
    - contents:
      - nameserver {{ownip }}
      - search {{ ad.realm }}

