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

{%- if ad.forcedns == True %}
/etc/sysconfig/network-scripts/ifcfg-eth0:
  file.line:
    - mode: ensure
    - content: PEERDNS=no
    - after: BOOTPROTO
{% endif %}

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
    - unless: nslookup infra1.{{ad.realm}}

/etc/nsswitch.conf:
  file.replace:
    - pattern: ^hosts:.*
    - repl: "hosts: files dns"

Remove passwd complexity:
  cmd.run:
    - name: samba-tool domain passwordsettings set --complexity=off

Passwd min length:
  cmd.run:
    - name: samba-tool domain passwordsettings set --min-pwd-length=1

/etc/samba/smb.conf:
  file.line:
    - content: dns forwarder = {{ ad.dnsfwd }}
    - match: "dns\ forwarder.*"
    - mode: replace

add line if replace did not work:
  file.line:
    - name: /etc/samba/smb.conf
    - content: dns forwarder = {{ ad.dnsfwd }}
    - mode: ensure
    - after: workgroup
    - unless: grep -q "dns forwarder" /etc/samba/smb.conf

