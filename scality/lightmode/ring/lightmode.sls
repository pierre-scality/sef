{% from "scality/map.jinja" import scality with context %}

configure-rs2-connector:
  scality_ring.configured:
    - ring: {{ scality.ring }}
    - supervisor: {{ scality.supervisor_ip }}
    - login: {{ scality.credentials.internal_user }}
    - passwd: {{ scality.credentials.internal_password }}
    - values:
        restapibwshostname: dlx1.msg.in.telstra.com.au
        restapibwsoldidcompat: 0
        restapibwslightmode: 1
        restapisrwsenable: 0
        restapiswsenable: 0
        chordbucketbwsacctenable: 0
        restapibwsnbreplicas: 3
