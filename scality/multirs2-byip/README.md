# Introduction

This formula is used to create multiple instance of RS2 process and use 1 different RS2 process on different interfaces.

The server needs to have several IP.

The service scality-rest-connector must be at least run once for confdb to be populated (Will be done by installer). 

This formula is to be run with state.sls after installation by installer.

## Configuration

### Modules 

Some code used in this state has been stripped from salt installer code.

We need to fix it :

* Replace the scality_rest_connector.py with the one included in this code directory

	This will add the declared function.

	cp /srv/scality/salt/formula/_states/scality_rest_connector.py /srv/scality/salt/formula/_states/scality_rest_connector.py.orig

	cp code/scality_rest_connector.py /srv/scality/salt/formula/_states/scality_rest_connector.py

* Add code to scal_utils.py 

	cp /srv/scality/salt/formula/_modules/scalutils.py /srv/scality/salt/formula/_modules/scalutils.py.orig

	cat code/add_to_scalutils.py >> /srv/scality/salt/formula/_modules/scalutils.py

* Reload all to salt 
```shell
salt * saltutil.sync_states
```	



The code for defining the interfaces to use for RS2 starts here : 
```yaml
{% for ctor in range(1,ctor_nbinstances+1) %}
...
{% set ctor_ip = salt['network.interface_ip']('eth%d' % loop.index) %}
```
In above case if number of instances is 2, interaces used will be eth1 and eth2.

With the number of instances defined at this line :
```yaml
{% set ctor_nbinstances = 2 %}
```

```yaml
{% for ctor in range(1,ctor_nbinstances+1) %}

{% set ctor_index = loop.index %}
{% set ctor_name = '%s-rs2-%d' % (grains['id'],loop.index) %}
{% set ctor_ip = salt['network.interface_ip']('eth%d' % loop.index) %}
{% set port = 8184 %}
{% set ring = scality.metadata_ring %}
.....
{% endfor %}
```
### Pillar 

Add pillar as (in scality-common.sls) :
```yaml
scality:
  metadata_ring: YOURRING
```

## Usage

git out multirs2 to /srv/scality/salt/local/scality 

do the configuration 

Run the state :
```shell
salt 'machine' state.sls scality.custom 
```

## Possible improvement

The code keep some relicat of former purpose of the script and should be reviewed.
Some paramters should go to the pillar.


## Status 
Tested on CentOS. Used on prod.

## Original writter
Herr Vedel
