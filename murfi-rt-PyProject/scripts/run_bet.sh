#!/bin/bash

subject=$1
session=ses-localizer
threshold=$2
data_path=/home/rt/rtsz/data/sub-${subject}/

bet ${data_path}${session}/anat/sub-${subject}_${session}_T1w ${data_path}${session}/anat/sub-${subject}_${session}_T1w_brain -R -f ${threshold} -g 0

fsleyes ${data_path}${session}/anat/sub-${subject}_${session}_T1w_brain.nii.gz
