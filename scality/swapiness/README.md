# This formula is to set the swapines for RH8+
See : https://access.redhat.com/solutions/6785021

# Usage 
'''
mkdir -p /srv/scality/salt/local/scality/swapiness/
cp init.sls /srv/scality/salt/local/scality/swapiness/
salt '*' state.sls scality.swapiness
'''

To apply the change reboot the server.
It may be possible to apply without change.

Verify the change with : 
'''
find /sys/fs/cgroup/memory/ -name memory.swappiness -exec cat {} \;|uniq -c
'''
