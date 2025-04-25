#!/bin/bash


PARTICIPANTS=("sub-remind2002", "sub-remind2018", "sub-remind2021",
              "sub-remind2037", "sub-remind2055", "sub-remind2058", 
              "sub-remind2059", "sub-remind2071", "sub-remind3007", 
              "sub-remind3010")


for PARTICIPANT in "${PARTICIPANTS[@]}"; do
    docker run --rm -it \
        -v /neurodata/mindful_brain_project/data/bids_data/:/data:ro \
        -v /neurodata/mindful_brain_project/data/fmriprep/:/out \
        -v /neurodata//neurodata/mindful_brain_project/data/fmriprep/fmriprep-23.2.1/sourcedata/freesurfer:/freesurfer \
        -v /neurodata/license.txt:/fslicense.txt:ro \
        -v /neurodata/work:/work \
        nipreps/fmriprep:23.2.1 \
        /data /out/fmriprep-23.2.1-ignorefieldmaps \
        participant \
        --participant-label "$input_subject" \
        -w /work --fs-license-file /fslicense.txt \
        --fs-no-reconall  \
        --fs-subjects-dir /freesurfer \
        --ignore fieldmaps 
done