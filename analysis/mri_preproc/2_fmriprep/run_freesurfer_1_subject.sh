#!/bin/bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <subject_id>"
    exit 1
fi

# Assign the input argument to a variable
input_subject=$1

docker run -tid \
    -v /neurodata/mindful_brain_project/data/bids_data/:/data:ro \
    -v /neurodata/mindful_brain_project/data/freesurfer/:/out \
    -v /neurodata/license.txt:/fslicense.txt:ro \
    -v /neurodata/work:/work \
    freesurfer/freesurfer:23.2.1 \
        recon-all -autorecon1 \
        -wsthresh 30 \
        -s $input_subject