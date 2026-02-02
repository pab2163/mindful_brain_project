#!/bin/bash
#
#SBATCH --job-name=j_fMRIprep
#SBATCH --partition=short
#SBATCH --time=10:00:00
#SBATCH -n 1
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
# Outputs ----------------------------------
#SBATCH --output=logs/%x.%A-%a.out
#SBATCH --error=logs/%x.%A-%a.err
# ------------------------------------------

STUDY=$1
fmriprep_version="21.0.0"	# which version you want to use (note this should be = singularity image . Example: fmriprep-20.2.1.simg = fmriprep-${fmriprep_versions}.simg)

####################################################
module load singularity/3.5.3

export FREESURFER_HOME=/work/swglab/software/freesurfer_7.0.0  #where my local copy of FS is
source $FREESURFER_HOME/SetUpFreeSurfer.sh

BIDS_DIR="$STUDY/rawdata"	# input files directory
DERIVS_DIR="$STUDY/derivatives/fmriprep_${fmriprep_version}_wo_FS"	#where I want the output files from fmriprep to be
WC_FILES="$STUDY/working_files/fmriprep_${fmriprep_version}_tmp"  #where the the workflow will be (i.e. fmriprer_wf, configfiles, bids.db...)

# Prepare some writeable bind-mount points.
TEMPLATEFLOW_HOST_HOME=/work/swglab/software/fMRIprep/.cache/templateflow
FMRIPREP_HOST_CACHE=/work/swglab/software/fMRIprep/.cache/fmriprep
mkdir -p ${TEMPLATEFLOW_HOST_HOME}
mkdir -p ${FMRIPREP_HOST_CACHE}


# Prepare derivatives folder
mkdir -p ${DERIVS_DIR}  # outdirectory for fmriprep
mkdir -p ${WC_FILES}    #outdir for workflow files

# Make sure FS_LICENSE is defined in the container.
export SINGULARITYENV_FS_LICENSE=$HOME/softwares/license.txt

# Designate a templateflow bind-mount point
export SINGULARITYENV_TEMPLATEFLOW_HOME="/templateflow"
SINGULARITY_CMD="singularity run --cleanenv -B $BIDS_DIR:/data -B $DERIVS_DIR:/my_outdir -B ${TEMPLATEFLOW_HOST_HOME}:${SINGULARITYENV_TEMPLATEFLOW_HOME} -B $WC_FILES:/work -B ${LOCAL_FREESURFER_DIR}:/fsdir /work/swglab/software/fMRIprep/fmriprep-${fmriprep_version}.simg"

# Parse the participants.tsv file and extract one subject ID from the line corresponding to this SLURM task.
subject=$( sed -n -E "$((${SLURM_ARRAY_TASK_ID} + 1))s/sub-(\S*)\>.*/\1/gp" ${BIDS_DIR}/participants.tsv )

# Remove IsRunning files from FreeSurfer
find ${LOCAL_FREESURFER_DIR}/sub-$subject/ -name "*IsRunning*" -type f -delete	#this will most likely give an error at the very beginning saying "find cant' find freesurfer/sub-xx but that's OK"

# Compose the command line
cmd="${SINGULARITY_CMD} /data /my_outdir participant --participant-label $subject -w /work -vv --omp-nthreads 8 --nthreads 12 --mem_mb 30000 --output-spaces MNI152NLin6Asym:res-2 --output-layout bids --ignore slicetiming --fs-license-file ${SINGULARITYENV_FS_LICENSE} --fs-no-reconall --notrack"


# Setup done, run the command
echo Running task ${SLURM_ARRAY_TASK_ID}
echo Commandline: $cmd
eval $cmd
exitcode=$?

# Output results to a table
echo "sub-$subject   ${SLURM_ARRAY_TASK_ID}    $exitcode" \
      >> ${SLURM_JOB_NAME}.${SLURM_ARRAY_JOB_ID}.tsv
echo Finished tasks ${SLURM_ARRAY_TASK_ID} with exit code $exitcode
exit $exitcode



#fixing perms 
chmod -R 770 ${DERIVS_DIR}/${subject}
chmod -R 770 ${WC_FILES}/fmriprep_wf/*${subject}*

