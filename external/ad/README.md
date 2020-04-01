# Create AD server 

This formula create a SMB based AD server 
It needs sernet samba version which offers samba-tool command
Still in devlopement

# Configuration
Copy the files in your salt formula root /ad directory 

Edit the ad.yaml file to set your environement
realm: <your realm DNS domain>
addomain: <windows domain>
adminpass: <admin password for Administrator user>
iface: <interface used for services>
reverse: < reverse name zone for iface like 200.10.in-addr.arpa>
dnsfwd: <dns server to forward request>
forcedns: true <to force the dns to ignore dhcp update in resolv.conf>

# Execute

Just run : 
salt <ADSERVER> state.sls ad
