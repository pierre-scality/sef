# lightmode

This formula is to tune rs2 to go in light mode 
This needs to be created before ring installation 

## Configuration

Copy the files under lightmode directory to /srv/scality/salt/local/

The state scality.rs2-full included here override formula/scality/rs2-full by not installing sindexd
lightmode.sls can be run after installation by running state.sls scality.ring.lightmode 

The following lines must be adapted 
```yaml
restapibwshostname: FQDN_NAME_FOR_RS2_DOMAIN
restapibwsnbreplicas: THE_COS_YOUNEED
```


## Usage 
In the local top.sls a call has to be added for highstate like 
```yaml
roles:ROLE_STORE:
  - match: grain
  - scality.rest-connector
  - scality.ring.lightmode
```

Then run the usual state.highstate

## Possible improvement

## Original writter
Herr Vedel
