# snmpd

This formula has 2 purpose :

1 - Provide a working snmpd conf that will replace existing one 

2 - Configure snmp on sup and snmptrad to get the trap

## Configuration
The base is from existing snmpd state.

It is intended to be in local tree (/srv/scality/salt/local/scality).

The init state is for all servers 

The sup state is to run after on sup only.

No need to change pillar but the local map.jinja has been modified

The following lines gives the trapsink of the hosts, so you could use another trapsink server
```yaml
        'trapsink': salt['pillar.get']('scality:supervisor_ip') 
```
In above sample we have 2 SSD that will hold respectivly odd and even disks


## Usage 
After copying the files :

Run salt '*' state.sls scality.snmpd 

Then on sup :
salt-call state.sls scality.snmpd.sup

##  Possible improvement

Cover only redhat 

Should separate sup and trapdconfig

## Original writter
Fork by PM
