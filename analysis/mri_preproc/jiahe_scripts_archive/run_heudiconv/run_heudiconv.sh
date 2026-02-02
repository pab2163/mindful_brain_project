#!/bin/bash

########################    INSTRUCTIONS
# request a computing node
# srun -p gpu -N 1 -n 1 --pty --export=ALL --gres=gpu:1 --mem=64Gb --time=08:00:00 /bin/bash
# have dicoms and task outputs in their corresponding folder 

########################     USAGE
# sh run_heudiconv.sh remind1005 loc


########################    ENVIRONMENT    ####################################
module load singularity/3.5.3
set -o errexit

# User inputs
subject="$1"
session="$2"
args=($@)

version="0.9.0"

# IN PATHS
main_proj='/work/swglab/data/remind'
dicom_dir=${main_proj}'/sourcedata/dicoms'
work_dir=${main_proj}'/working_files/heudiconv_'${version}
scripts_dir=${main_proj}'/scripts/run_heudiconv'

########################    BEGIN    ####################################

# help
if [ ${subject} = help ]; then
  echo "$(tput setaf 1)USAGE: $(basename $0) <subject ID: remindXXX> <session_name: loc/nf>"
  exit 1
fi


# Zipping and preparing Dicoms folder
if [ ! -d ${dicom_dir}/sub-${subject}_ses-${session} ];then
 echo "missing dicoms folder. transfer dicoms (unzipped) here" ${dicom_dir}
   
elif [ -d ${dicom_dir}/sub-${subject}_ses-${session} ];then
    if [ ! -f ${DICOM_DIR}/sub-${subject}_ses-${session}.zip ];then

     echo "+ ZIPPING FOLDER FOR ARCHIVAL PURPOSE"
     zip -r ${dicom_dir}/sub-${subject}_ses-${session}.zip ${dicom_dir}/sub-${subject}_ses-${session}
    fi

  #Delete MoCo series from unzipped dicoms so they do not get converted
  rm -r ${dicom_dir}/sub-${subject}_ses-${session}/*/MoCoSeries*
     
  #Preparing a dicoms folder containing all the dicom files
  mkdir ${dicom_dir}/sub-${subject}_ses-${session}/dicom
  mv ${dicom_dir}/sub-${subject}_ses-${session}/*/*/IM-* ${dicom_dir}/sub-${subject}_ses-${session}/dicom/
#fi


# build singularity command
cmd="singularity run --cleanenv -B /work/swglab /work/swglab/software/heudiconv/heudiconv_${version}.simg 
  -d ${dicom_dir}/sub-{subject}_ses-{session}/dicom/*.dcm
  -o ${main_proj}/rawdata
  -f ${scripts_dir}/heuristic.py 
  -c dcm2niix
  --bids
  -s ${subject} 
  -ss ${session} 
  --overwrite"


echo "+ CONVERTING dcm2nii for SUBJECT ${subject} SESSION ${session}"
printf "+ CONVERSION COMMAND IS:\n\n"
printf "${cmd}\n\n"
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"


# Run the conversion.
$cmd

echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "+ dcm2nii CONVERSION SUCCESFULL"
echo "INSPECT OUTPUT; IF ALL CORRECT, DELET UNZIPPED DICOMS USING FOLLOWING COMMAND"
echo "rm -r ${dicom_dir}/sub-${subject}_ses-${session}"

# RUN THIS LINE IF HEUDICONV HAS FAILED ONE TIME TO CLEAR THE ERROR LOG
# ** UPDATE THIS PATH
#rm -r /work/swglab/data/remind/rawdata/.heudiconv/${subject}/ses-${session}
echo "++++ FINISHED ++++"

chmod -R 770 ${main_proj}/rawdata/sub-${subject}
chmod -R 770 ${main_proj}/rawdata/.heudiconv
