{% from "scality/samba/samba.jinja" import samba with context%}

tune cache:
  file.serialize:
    - name: {{ samba.sfusedconf }}
    - dataset:
        "general":
          acl: true
          group_check: true
          dir_update_log_size: 16384
          case_insensitive: true
        "ino_mode:2":
          update_log_max_size: 16384
{% if samba.sfusedquota == True %}
        "quota":
          "enable": true,
          "enforce_limits": true,
          "rpc_enable": true,
          "accuracy_step1_enable": true
{% endif %}
{%- if samba.dlm8 == true %}
        "dlm":
          "enable": 1,
          "rpc_address_selector": "{{ samba.dlm8_network}}"
{% endif %}
    - formatter: json
    - create: False
    - merge_if_exists: True
    - backup: minion

scality-sfused:
  service.running:
    - restart: True
    - watch:
      - file: {{ samba.sfusedconf }}
