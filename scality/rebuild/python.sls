/etc/python/cert-verification.cfg:
  file.replace:
    - pattern: '^verify=.*'
    - repl: verify=disable
