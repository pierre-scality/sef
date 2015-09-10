10GB-formula
================

This formula helps to tune 10GB interfaces.

Most of the parameters are done with systcl and reboot proof.



## Available states

A single state that comes with set_irq_affinity.sh 

## Pillar Configuration
--------------------

The pillar need a list under scality tree of the interfaces to set 10GB like


``` YAML
scality:
  iface_10Gb: 
      - eth0
```

## Salt Minion Configuration

## Notes / Improvement
The txqueuelen 10000 is just running ifconfig which is not kept at boot.
Should be added to rc.local or so.

This has only been tested on CentOS (not Ubuntu).


## Original writter 
