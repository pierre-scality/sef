
include:
  - scality.sagentd.registered
  - scality.sproxyd.added

{% from "scality/map.jinja" import scality with context %}

config-sproxyd-connector:
  scality_nasdk_connector.configured:
    - name: {{ grains['id'] }}-sproxyd
    - ring: {{ scality.data_ring }}
    - supervisor: {{ scality.supervisor_ip }}
    - login: {{ scality.credentials.internal_user }}
    - passwd: {{ scality.credentials.internal_password }}
    - require:
      - scality_nasdk_connector: add-sproxyd-connector
    - watch_in:
      - service: restart-scality-sproxyd
    - defaults:
        general:
          ring: {{ scality.data_ring }}
          n_workers: 500
          n_responders: 500
          syslog_facility: local0
          split_enabled: True
          split_chunk_size: 33554432
          split_threshold: 67108864
        'ring_driver:0':
          type: chord
          alias: {{ scality.data_ring_stg.path }}_chord
          ring: {{ scality.data_ring_stg.ring }}
          deferred_writes_enabled_by_policy: True
          deferred_deletes_enabled_by_policy: True
        'ring_driver:1':
          type: chord
          alias: {{ scality.data_ring_dev.path }}_chord
          ring: {{ scality.data_ring_dev.ring }}
          deferred_writes_enabled_by_policy: True
          deferred_deletes_enabled_by_policy: True
        'ring_driver:2':
          type: chord
          alias: {{ scality.data_ring_tst.path }}_chord
          ring: {{ scality.data_ring_tst.ring }}
          deferred_writes_enabled_by_policy: True
          deferred_deletes_enabled_by_policy: True

restart-scality-sproxyd:
  cmd.run:
    - name: service scality-sproxyd restart
