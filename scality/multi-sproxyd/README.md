# sproxy multi

Formulat to create different ring drivers and create apache vhost to each ring driver

## Configuration
The ring config, port and proxy path are configured in pillar.

The following lines are describing the ssd/disk allocation :
```yaml
data_ring_all: DATA_STG,DATA_DEV,DATA_TST
data_ring_stg:  
  ring: DATA_STG
  path: stg
  cidr: "10.94.40.0/24"
data_ring_dev:  
  ring: DATA_DEV
  path: dev
  cidr: "10.93.40.0/24"
data_ring_tst:  
  ring: DATA_TST
  path: tst  
  cidr: "10.95.40.0/24"
```


## Usage 
A new state file to apply new config afeter initial setup is done.
```shell
salt -G 'roles:ROLE_CONN_SPROXYD' state.sls apply-conf.sls
```

Could be integrated in highstate but by default sproxyd is not configured.

## Possible improvement
Need to make a loop from pillar instead of ugly iterative code.

## Original writter
PM
