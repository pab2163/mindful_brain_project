#!/bin/bash


# User inputs
subject="$1"
session="$2"
args=($@)


# PATHS
main_proj="/neurodata/mindful_brain_project"
work_dir="${main_proj}/work"
dicom_dir="${main_proj}/data/dicom_prepped_for_heudiconv/${subject}/${session}"
scripts_dir="${main_proj}/mindful_brain_project/analysis/bidsification"
output_dir="${main_proj}/data/bids_data"

echo ${dicom_dir}

mkdir ${output_dir}



########################    BEGIN    ####################################

# # help
# if [ ${subject} = help ]; then
#   echo "$(tput setaf 1)USAGE: $(basename $0) <subject ID: remindXXX> <session_name: loc/nf>"
#   exit 1
# fi


# Make a list of all the dicoms in the session
session_dicoms=$(find "$dicom_dir" -type f -name "*.dcm")
length=$(echo "$session_dicoms" | wc -l)
echo "Number of files in session_dicoms: $length"


# build docker command
cmd="docker run -ti --rm \
  -v /neurodata:/neurodata \
  -v ${work_dir}:/work \
  -v ${dicom_dir}:/dicom_dir \
  -v ${output_dir}:/output_dir \
  -v ${scripts_dir}:/scripts_dir \
  nipy/heudiconv:latest \
  --files ${session_dicoms} \
  -o /output_dir \
  -f /scripts_dir/heuristic.py \
  -c dcm2niix \
  --bids \
  -s ${subject} \
  -ss ${session} \
  --overwrite"



echo "+ CONVERTING dcm2nii for SUBJECT ${subject} SESSION ${session}"
printf "+ CONVERSION COMMAND IS:\n\n"
printf "${cmd}\n\n"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


# Run the conversion.
$cmd

# echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
# echo "+ dcm2nii CONVERSION SUCCESFULL"
# echo "INSPECT OUTPUT; IF ALL CORRECT, DELET UNZIPPED DICOMS USING FOLLOWING COMMAND"
# echo "rm -r ${dicom_dir}/sub-${subject}_ses-${session}"

# # RUN THIS LINE IF HEUDICONV HAS FAILED ONE TIME TO CLEAR THE ERROR LOG
# # ** UPDATE THIS PATH
# #rm -r /work/swglab/data/remind/rawdata/.heudiconv/${subject}/ses-${session}
# echo "++++ FINISHED ++++"

# chmod -R 770 ${main_proj}/rawdata/sub-${subject}
# chmod -R 770 ${main_proj}/rawdata/.heudiconv
