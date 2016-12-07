# syctl

This formula applies the sysctl parameters define in a param file

## Configuration

Configuration files are written to use {file_roots}/sysctl/

Copy the file in /src/scality/salt/local/sysctl/ directory.

Put systctl parameters in file sysctl.yaml

sysctl.jinja transforms this parametres in pillar dict

apply.sls apply this parameters and create in /tmp/ a file with the list of parameters.

The following lines are describing the ssd/disk allocation :
```yaml
net.ipv4.tcp_mtu_probing: 1
net.ipv4.tcp_tw_reuse: 1
net.ipv4.conf.all.accept_redirects: 0
```

## Usage 
After modifying the yaml file just run the apply sls.

```python
salt -G roles:ROLE_STORE  state.sls sysctl.apply
```

Then run the usual state.highstate

## Possible improvement

## Original writter
Pierre Merle
