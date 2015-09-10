# mutli-rs2 by port 

This formula is used to create multiple instance of RS2 process by seggrecating on PORT 

This will replace the scality-rest-connector with scality-multirs2

The service scality-rest-connector must be at least run once for confdb to be populated 

If multirs formula are to be run at installation time please uncomment the appropriate section in custom.sls

This formula can be run with state.sls after installation by installer.

## Configuration
The state has been designed to be stored in scality/multirs2, as additionnal state of rest-connector.
it is assumed that rest-connector as been started at least one time.

```yaml
```


## Usage 
```yaml
```


## Notes / Improvement

* Need package xmlstarlet
* Delete rest-connector files
* Check log rotation 
* remove sproxy part 


## Status 

## Original writter
Herr Vedel
