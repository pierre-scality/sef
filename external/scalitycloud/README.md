scality cloud post 
================

States to run after salt installation

## Available states
The init sls is basically browsing others sls in the dir.
You can add and remove lines in init.sls like :
'''
  - .packages
'''

## Sub sls 

### rootperm.sls 

Correct the default ssh setting
Change ssh setting to allow password login and copy sup pub key to authorized_keys.
Create id_rsa files
Create a password for root 

One need to change the password in the state, generate password with :
'''
openssl passwd -1
'''

### hosts.sls 
Add hostname.
Before operations hostname must have been set with command hostname on each hosts.
Could change hostname with minion id.

### packages 
Add the list of packages you want to be installed.
It is a list in file pkg.yaml where you have 1 pkg / line starting with - like :
- tmux
- dstat 

## Original writter 
PM
