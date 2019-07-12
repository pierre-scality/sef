
{% set bkpdir = "/var/tmp/{{ grains['nodename'] }}/" %}

{% set ngx = salt['pkg.version']('scality-nginx-cache') %}
{% if 'ROLE_STORE' in grains['roles'] %}
{% set bkp = 'common.include' %}
{% elif 'ROLE_CONN_CDMI' in grains['roles'] %}
{% if ngx %}
{% set bkp = 'common.include.nginx' %}
{% else %}
{% set bkp = 'common.include.cdmi' %}
{% endif %}
{% elif 'ROLE_CONN_NFS' in grains['roles'] %}
{% set bkp = 'common.include.nfs' %}
{% endif %}

create backup dir:
  file.directory:
    - name: {{ bkpdir }}

create custom backup file:
  file.managed:
    - source: salt://rebuild/{{ bkp }}
    - name: /etc/scality-common/backup.conf.d/common.include

take backup:
  cmd.run:
    - name: /usr/bin/scality-backup --common-include /etc/scality-common/backup.conf.d/common.include -b {{ bkpdir }}{{ grains['nodename'] }}

tar backup:
  cmd.run:
    - name: tar -C {{ bkpdir }} -cf {{ bkpdir }}{{ grains['nodename'] }}.tar ./{{ grains['nodename'] }} 


tar standard backup:
  cmd.run:
    - name: tar -C /var/lib/scality/backup  -cf {{ bkpdir }}{{ grains['nodename'] }}.backup.tar .

tar salt backup:
  cmd.run:
    - name: tar -C /etc/salt/  -cf {{ bkpdir }}{{ grains['nodename'] }}.salt.tar .

{% if 'ROLE_STORE' in grains['roles'] %}
mark disks:
  cmd.run:
    - name: for i in $(ls -d /scality/*) ; do touch $i/$(basename $i) ; done
{% endif %}

get scality package list:
  cmd.run:
    - name: rpm -qa|grep scality > {{ bkpdir }}{{ grains['nodename'] }}.pkg.list

get all package list:
  cmd.run:
    - name: rpm -qa > {{ bkpdir }}{{ grains['nodename'] }}.all.pkg.list

{% if not ngx %}
{% if 'ROLE_CONN_CDMI' in grains['roles'] %}
put mock bucket:
  cmd.run:
    - name: curl -s -XPUT http://localhost/mock/

cp test file:
  cmd.run:
    - name: cp /var/log/messages {{ bkpdir }}

put mock data:
  cmd.run:
    - name: curl -s -XPUT  http://localhost/mock/messages --data-binary @{{ bkpdir }}messages

sum test file:
  cmd.run:
    - name: sum {{ bkpdir }}messages
{% endif %}
{% endif %}

