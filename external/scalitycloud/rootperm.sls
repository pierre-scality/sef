/etc/ssh/sshd_config:
  file.comment:
    - regex: PasswordAuthentication.*no

sshd:
  service.running:
    - enable: true
    - reload: true
    - watch:
      - file: /etc/ssh/sshd_config

root:
  user.present:
    - password: $1$B7pp7UQJ$jrhbpVaE8pi5ShBB1pCpJ.

generate ssh keys:
  cmd.run:
    - name: ssh-keygen -q -N '' -f /root/.ssh/id_rsa
    - unless: test -f /root/.ssh/id_rsa.pub

authorize sup key:
  ssh_auth.present:
    - user: root
    - source: /root/.ssh/id_rsa.pub
    - config: /root/.ssh/authorized_keys

