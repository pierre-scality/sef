# ha1

This formula set up sagentd to use ha1 on S3 sproxyd instances

## Configuration
Set which is the ip address sproxyd is running, sproxyd count per sproxyd instance and the docker conf directory on in  ha1.yaml file
```yaml
        interface: bond0
 	sproxyd_count: 4
	s3_dir: /scality/ssd1/s3/

```


## Usage 
Copy the files to /srv/scality/salt/local/scality/ha1s3
Copy the ha1.yaml.sample to ha1.yaml and tune the parameters

Then run on all docker hosts 
Lastly run federation against sproxy 

```yaml
ENV=s3config
salt -G roles:ROLE_S3   state.sls scality.ha1s3.sagentd
salt -G roles:ROLE_SUP  state.sls scality.ha1s3.sup
./ansible-playbook -i env/${ENV}/inventory run.yml  --skip-tags requirements,run::images -t sproxyd -f 1
```

Use the role is S3/MD are collocated or a list if not.
salt -L srv0,srv-1,srv-2,srv-3,srv-4  state.sls scality.ha1s3.sagentd

##  Possible improvement
use salt orch to run everything is  a single step 
Do we realy want to run fedeation through salt ... 

## Original writter
PM
