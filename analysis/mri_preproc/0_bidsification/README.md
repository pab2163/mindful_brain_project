# Documentation of Bidsification Pipeline

## Step 1: Pull Data to Auerbach Lab Server

**CU**:
* From Flywheel, download DICOMS ONLY for a single subject and unzip
* Add the subject folder to `/Volumes/columbia/mbNF_MDD/DATA/MRI/flywheel_dicom/flywheel/auerbach/REMIND`

**NEU**:
* (NEU STAFF) Transfer files from scanner Mac computer to Discovery
* (CU STAFF): While logged in to Auerbachlab server, run `0_rsync_from_neu.py [sub-remind####_ses-#$&$]` to rsync files to the server. *Note: this will require password access to Discovery cluster and should be run once per SESSION (2x per subject)*