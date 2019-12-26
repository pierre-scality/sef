# Create AD server 

This formula create a SMB based AD server 
It needs sernet samba version which offer samba-tool command

# Configuration
Copy the files in your salt formula root /ad directory 

Edit the ad.yaml file to set your environement

# Execute

Just run : 
salt <ADSERVER> state.sls ad

The dns.sls is here to setup only resolv.conf because dhcp may update the file on reboot
