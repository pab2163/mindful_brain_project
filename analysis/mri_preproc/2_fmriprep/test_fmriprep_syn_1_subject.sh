#!/bin/bash

# Check if an argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <subject_id>"
    exit 1
fi

# Assign the input argument to a variable
input_subject=$1

docker run -tid --rm \
    -v /neurodata/mindful_brain_project/data/bids_data/:/data:ro \
    -v /neurodata/mindful_brain_project/data/fmriprep/:/out \
    -v /neurodata/license.txt:/fslicense.txt:ro \
    -v /neurodata/work:/work \
    nipreps/fmriprep:23.2.1 \
    /data /out/fmriprep-23.2.1-testsyn \
    participant \
    --participant-label "$input_subject" \
    --use-syn-sdc \
    -w /work --fs-license-file /fslicense.txt
