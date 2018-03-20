# corosync

This formula configures corosync for dlm DACO.

## Configuration

It is installing package creating corosync.conf based on local definition file and hosts having role ROLE_COROSYNC

corosync.yaml file must be configured according local params
```yaml
	bindnetaddr: 10.100.0.0 
	cluster_name: dlm
	corosync_if: eth0
```

## Usage 
After copying the files to /srv/scality/salt/local/sclaity/corosync:

1 - Add the role ROLE_COROSYNC on 5 of the store nodes :
```shell
	H=hostprefix
	salt ${H}[1-5] grains.append roles ROLE_COROSYNC
```

2 - Run the salt state :
```shell
	salt -G roles:ROLE_COROSYNC sclality.corosync
```

##  Possible improvement
cororole: ROLE_COROSYNC

Cover only redhat 

## Original writter
PM
