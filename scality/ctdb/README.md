# ha1

Setup a ctdb clluster

## Configuration
Configuration is in ctdb.yaml file
clustername: ctdbcluster
  => ctdb cluster name
security: ads
  => Enable or disable winbind in ctdb
smbservices: ['sernet-samba-nmbd','sernet-samba-winbindd','sernet-samba-smbd']
  => This line is to restart smb should not change
ctdbmember:
  => list member of the cluster (python list format)
ctdbvip:
  => list the vip (with iface python list format)

## Usage
Copy the files to /srv/scality/salt/local/scality/ctdb
After configuring standard smb (no ads registration) 
salt <1st server> state.sls scality.ctdb 
ssh this server and register in the AD (net ads join) 
run scality.ctdb on all remaining hosts of the cluster

##  Possible improvement
change for fileid in smb file is not indepotent. Probably there is a better way to do.
Could merge samba states and ctdb 
Add NFS support 

## Original writter
PM
