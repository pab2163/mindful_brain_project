# Notes for Moving Files Around

## NEU Discovery Cluster

### Logging in
* NEU staff will need to set up an account for login info and access
* To log in with ssh: 

```bash
ssh [USERNAME]@login.discovery.neu.edu
```
e.g. `ssh p.bloom@login.discovery.neu.edu` 
Then will need to enter discovery password


### Where are SWGLab files? 

Files for remind:
`/work/swglab/data/remind/`

### File transfers: do NOT use the login node. Use transfer node instead

* Instead, log with ssh via
```bash
ssh [USERNAME]@xfer.discovery.neu.edu
```
e.g. `ssh p.bloom@xfer.discovery.neu.edu`
Then will need to enter same discovery password


## RSYNC

### Sending data from discovery to AWS instance

* general format is `rsync -avz [current_path_to_files] [destination_path]`
* paths will include address to location you are NOT currently logged into (e.g. `bloompa@172.19.1.68` for AWS instance)
* `--dry-run` flag can be used to test without sending files
* May not be able to do this directly - I think have to be on NYSPI network to access the AWS instance I think. So we first pull from discovery to auerbach lab server, then from Auerbach server to AWS

#### Step 1:

Should be logged into nyspi network on lab server

```bash
rsync -avz p.bloom@xfer.discovery.neu.edu:/work/swglab/data/remind/rawdata from_neu
```


#### Step 2:

From lab server to AWS instance

```bash
rsync -avz from_neu bloompa@172.19.1.68:/neurodata/
```