#!/bin/bash

# No participant specified here, so it will try to run on all subjects serially

docker run -tid --rm \
    -v /neurodata/mindful_brain_project/data/bids_data/:/data:ro \
    -v /neurodata/mindful_brain_project/data/fmriprep/:/out \
    -v /neurodata/license.txt:/fslicense.txt:ro \
    -v /neurodata/work:/work \
    nipreps/fmriprep:23.2.1 \
    /data /out/fmriprep-23.2.1 \
    participant \
    -w /work --fs-license-file /fslicense.txt
