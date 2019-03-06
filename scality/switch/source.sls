configure geo connector:
  salt.state:
    - tgt: 'roles:ROLE_GEO'
    - tgt_type: grain
    - sls: scality.switch.state.geosource

configure cdmi connector:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
    - sls: scality.switch.state.cdmisource

