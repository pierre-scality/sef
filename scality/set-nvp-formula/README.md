# set-nvp

This formula move the bizobj disk to ssd device

## Configuration
The SSD location are not calculted and formula must be tuned to fit with HW

The following lines are describing the ssd/disk allocation :
```yaml
{% set nvp = {} %}
{% do nvp.update({1: (1, 3, 5, 7, 9, 11)}) %}
{% do nvp.update({2: (2, 4, 6, 8, 10, 12)}) %}
{%- for ssd, hdds in nvp.iteritems() %}
{%- for hdd in hdds %}
```
In above sample we have 2 SSD that will hold respectivly odd and even disks


## Usage 
In the local top.sls a call has to be added for highstate like 
```yaml
roles:ROLE_STORE:
  - match: grain
  - scality.node.configured
  - scality.node.set-nvp
  - scality.rest-connector
```

Then run the usual state.highstate

## Possible improvement

## Original writter
Herr Vedel
