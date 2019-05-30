
install salt and workaround pkg:
  pkg.installed:
    - sources:
      - salt-repo-2016.3-2: salt://rebuild/salt-repo-2016.3-2.el7.noarch.rpm
      - scality-uwsgi-workaround-1.0-2: salt://rebuild/scality-uwsgi-workaround-1.0-2.el7.x86_64.rpm

salt-minion:
  pkg.installed:
    - fromrepo: salt-repo-2016.3-2

create minion.conf:
  file.managed:
    - source: salt://rebuild/minion.conf.tmpl
    - template: jinja
    - name: /etc/salt/minion.d/minion.conf

stat salt-minion:
  service.running:
    - enable: True
    - name: salt-minion


sync salt:
  module.run:
    - name: saltutil.sync_all

