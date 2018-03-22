# corosync

This formula configures corosync for dlm DACO.

## Configuration

It is installing package creating corosync.conf based on local definition file and hosts having role ROLE_COROSYNC and ROLE_DLM
Role ROLE_COROSYNC should be assigned to 5 of the store nodes 
Roles ROLE_DLM should be assigned to fuse connectors that belongs to the dlm cluster

store node will have a vote in the quorum but not dlm nodes.

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
	H=nodeserver
	salt ${H}[1-5] grains.append roles ROLE_COROSYNC
	H=fuseconnectors
	salt ${H}[1-x] grains.append roles ROLE_DLM
```

2 - Run the salt state :
State dlm includes corosync.
```shell
	salt -G roles:ROLE_COROSYNC state.sls scality.corosync.corosync
	salt -G roles:ROLE_DLM state.sls scality.corosync.dlm
```

##  Possible improvement
It is possible that store nodes and dlm cluster nodes are not sharing the same if.
Using pillar to define corosync interface could be better.

Cover only redhat 

## Original writter
PM
