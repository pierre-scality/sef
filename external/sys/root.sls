{% set enableroot = True %} 

{% if enableroot %}
  {% set root_login_setting = 'PermitRootLogin yes' %}
{% else %}
  {% set root_login_setting = '#PermitRootLogin no' %}
{% endif %}

manage_ssh_root_login:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^\s*#?PermitRootLogin\s+.*'
    - repl: '{{ root_login_setting }}'


uncomment_ssh_password_auth:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^#PasswordAuthentication\s+yes'
    - repl: 'PasswordAuthentication yes'

rename_cloud_init_ssh_config:
  file.rename:
    - source: /etc/ssh/sshd_config.d/50-cloud-init.conf
    - name: /etc/ssh/sshd_config.d/50-cloud-init.conf.remove
    - force: true

set_root_password:
  user.present:
    - name: root
    - password: '$1$2ol/Ce/q$jUl42XJu5j19Z7UPwiSOo1'
    - enforce_password: True

restart_sshd_service:
  service.running:
    - name: sshd
    - watch:
      - file: uncomment_ssh_password_auth
      - file: rename_cloud_init_ssh_config
      - file: manage_ssh_root_login

