{% from "scality/samba/samba.jinja" import samba with context%} 
sernet:
  pkg.installed:
    - pkgs:
      - sernet-samba
      - sernet-samba-client
      - sernet-samba-winbind

/etc/default/sernet-samba:
  file.replace:
    - pattern: SAMBA_START_MODE.*
    - repl: 'SAMBA_START_MODE="classic"'

{% for i in ['passwd','shadow','group'] %}
nss {{ i }}:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: "^{{ i }}: .*"
    - repl: "{{ i }}:\t{{samba.nssmode}}"
{% endfor %}
  
/tmp/system-auth:
  file.copy:
    - source: /etc/pam.d/system-auth

/etc/pam.d/system-auth_auth:
  file.append:
    - name: /etc/pam.d/system-auth
    - text: "auth        sufficient    pam_winbind.so"

/etc/pam.d/system-auth_session:
  file.append:
    - name: /etc/pam.d/system-auth
    - text: "session        optional    pam_winbind.so"

dns update:
  file.prepend:
    - name: /etc/resolv.conf
    - text: 
      - search {{ samba.search }}
{%- for srv in samba.nameserver %}
      - nameserver {{ srv }}
{%- endfor %} 

fix include.d:
  file.comment:
    - name: /etc/krb5.conf
    - regex: ^includedir /etc/krb5.conf.d/

uncomment first:
  file.uncomment:
    - regex: default_realm
    - name: /etc/krb5.conf

add realm:
  file.replace: 
    - pattern: default_realm.*
    - name: /etc/krb5.conf
    - repl: default_realm = {{ samba.realm }} 
    
