#!/bin/bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <subject_id>"
    exit 1
fi

# Assign the input argument to a variable
input_subject=$1

# Set FreeSurfer paths
export FS_SUBJECT_DIR_LOCAL=/neurodata/mindful_brain_project/data/freesurfer/
export LICENSE_FILE=/neurodata/license.txt
export WORK_DIR=/neurodata/work
export INPUT_DIR=/neurodata/mindful_brain_project/data/bids_data/${input_subject}/ses-loc/anat/
export FS_IMAGE=freesurfer/freesurfer:7.2.0

# Run FreeSurfer inside Docker
docker run -tid \
    -v "$FS_SUBJECT_DIR_LOCAL":/usr/local/freesurfer/subjects/ \
    -v /neurodata/license.txt:/license.txt:ro \
    -e FS_LICENSE='/license.txt' \
    -v "$WORK_DIR":/work \
    -v "$INPUT_DIR":/input \
    -e SUBJECTS_DIR=/usr/local/freesurfer/subjects/ \
    $FS_IMAGE \
    recon-all -autorecon-all \
        -s "$input_subject" \
        -i /input/"${input_subject}"_ses-loc_T1w.nii.gz
