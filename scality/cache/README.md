# Introduction

This formula deploy the nginx lua cache in place of existing dewpoint installation

Nginx lua come from this repo : https://bitbucket.org/scality-ts/nginxcache/src

It covers the dewpoint configuration that needs to be copied and tuned locally before deployement

The source cache dev is provided as a tar file. 

It may be recompiled and replaced if needed.

## Configuration

Copy your original source dewpoint.sofs file as  dewpoint-sofs.js.nocache

Make the neeed modifications in dewpoint-sofs.js.nocache

Same thing for dewpoint.js

A local copy of config file will be done on first run.

The nginx configuration is sca-lb.conf that you may need to modify.

It does not cover multiple instances of dewpoint.

The salt cache source must be in {saltroot}/salt/local/cache/

The stripe  size, inomode2 cache type and other few parameters are changed as this diff :

```yaml
14,15c14,15
<         "size": 8388608, 
<         "type": "write_through"
---
>         "size": 1000000000, 
>         "type": "stripe"
55a56
>         "read_ahead": "8192ki", 
57,58c58
<         "stripe_size": 2097152, 
<         "uncached_window": 2097152,
---
>         "stripe_size": 4194304, 
84d83
<         "stripe_size": 2097152,
```

Sample files are provided with .sample extentions.

### Usage 

# Installation 
Run salt -G roles:ROLE_CONN_CDMI state.sls scality.cache.install 

# Revert back to httpd/dewpoint
Run salt -G roles:ROLE_CONN_CDMI state.sls scality.cache.cleanup 

In install.sls change the rpm version if needed here  
```yaml
{% set cacherpm = "scality-nginx-cache-2-7.x86_64.rpm" %}

```
### Pillar 

Uneeded

## Possible improvement

Add multi instance dewpoint 

Clean up the source scality-cache package to not overwrite dewpoint config.

## Status 
Tested on CentOS. Used on prod.

## Original writter
Pierre Merle
