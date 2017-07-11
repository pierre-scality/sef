/etc/ssh/sshd_config:
  file.replace:
    - pattern: ^PasswordAuthentication.*
    - repl: PasswordAuthentication yes 
    - append_if_not_found: True

sshd:
  service.running:
    - enable: true
    - reload: true
    - watch:
      - file: /etc/ssh/sshd_config

root:
  user.present:
    - password: $1$Fm6s6N09$t3m.IQ/ZawwfUf.IMlqcG0

authorize sup key:
  ssh_auth.present:
    - user: root
    - source: salt://scalitycloud/id_rsa.pub
    - config: /root/.ssh/authorized_keys

