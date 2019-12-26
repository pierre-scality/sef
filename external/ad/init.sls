{% from "ad/ad.jinja" import ad with context%} 
{% set ownip = grains['ip4_interfaces']['eth0'][0] %}

/etc/krb5.conf:
  file.comment:
    - regex: ^includedir.*

sernet-samba-ad:
  pkg.installed

cifs-utils:
  pkg.installed:
    - fromrepo: base

/etc/default/sernet-samba:
  file.replace:
    - pattern: SAMBA_START_MODE.*
    - repl: 'SAMBA_START_MODE="ad"'

/etc/resolv.conf:
  file.managed:
    - contents:
      - nameserver {{ownip }}
      - search {{ ad.realm }}

Create AD server:
  cmd.run:
    - name: samba-tool domain provision --use-rfc2307 --server-role=dc --use-rfc2307 --dns-backend=SAMBA_INTERNAL --realm={{ ad.realm }}  --domain={{ad.addomain}} --adminpass="{{ ad.adminpass }}"

Start AD server:
  service.running:
    - name: sernet-samba-ad
    - enable: true

Create reverse zone:
  cmd.run:
    - name: samba-tool dns zonecreate {{ad.realm}} {{ ad.reverse }} -U administrator --password={{ ad.adminpass }}

Create ad srv entry in DNS:
  cmd.run:
    - name: samba-tool dns add {{ ownip }}  {{ad.realm}} {{ grains['host']  }} A {{ ownip }} -U administrator --password={{ ad.adminpass }}

/etc/nsswitch.conf:
  file.replace:
    - pattern: ^hosts:.*
    - repl: "hosts: files dns"
