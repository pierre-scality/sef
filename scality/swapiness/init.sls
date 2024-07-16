set swapiness v2:
  file.managed:
    - name: /etc/sysctl.d/10-swapiness-cgroup.conf
    - contents:
      -  vm.force_cgroup_v2_swappiness=1

