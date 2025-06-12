#!/bin/bash


# completed: 2002, 2018, 2021
PARTICIPANTS=(sub-remind2110)


for PARTICIPANT in "${PARTICIPANTS[@]}"; do
    echo "$PARTICIPANT" 
    docker run --rm \
        -v /neurodata/mindful_brain_project/data/bids_data/:/data:ro \
        -v /neurodata/mindful_brain_project/data/fmriprep/:/out \
        -v /neurodata/mindful_brain_project/data/fmriprep/fmriprep-23.2.1/sourcedata/freesurfer:/freesurfer \
        -v /neurodata/license.txt:/fslicense.txt:ro \
        -v /neurodata/work:/work \
        nipreps/fmriprep:23.2.1 \
        /data /out/fmriprep-23.2.1-ignorefieldmaps \
        participant \
        --participant-label "$PARTICIPANT" \
        -w /work --fs-license-file /fslicense.txt \
        --fs-no-reconall  \
        --fs-subjects-dir /freesurfer \
        --ignore fieldmaps 
done
