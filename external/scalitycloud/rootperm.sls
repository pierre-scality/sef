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
    - password: $1$ExZrpF5T$tgNSK3gMxDfMQnik.0tB4/

authorize sup key:
  ssh_auth.present:
    - user: root
    - source: salt://scalitycloud/id_rsa.pub
    - config: /root/.ssh/authorized_keys

