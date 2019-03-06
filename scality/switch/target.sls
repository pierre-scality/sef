configure geo connector:
  salt.state:
    - tgt: 'roles:ROLE_GEO'
    - tgt_type: grain
    - sls: scality.switch.state.geotarget

configure cdmi connector:
  salt.state:
    - tgt: 'roles:ROLE_CONN_CDMI'
    - tgt_type: grain
    - sls: scality.switch.state.cdmitarget

