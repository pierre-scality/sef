scality cloud post 
================

States to run after salt installation

## Available states

### ssh 
Change ssh setting to allow password login and copy sup pub key to authorized_keys.
Create id_rsa files
Create a password for root 

One need to change the password in the state, generate password with :
'''
openssl passwd -1
'''

## Original writter 
PM
