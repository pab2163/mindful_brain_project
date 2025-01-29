# USAGE
#sh a_run_fMRIprep.sh b_sbatch_fMRIprep_W_FS.slurm

###############################################################
# IMPORTANT: download a copy of Freesurfer license (https://surfer.nmr.mgh.harvard.edu/registration.html) into user's home directory at this location: ~/softwares/license.txt

# you will most likely see the following error at the very beginning of the fMRIprep output:
# "find cant' find freesurfer/sub-xx "
# this is not a problem. You can ignore it

#####################
# RUN IT
export STUDY=/work/swglab/data/remind
which_sbatch=$1
sbatch --array=1-$(( $( wc -l $STUDY/rawdata/participants.tsv | cut -f1 -d' ' ) - 1 )) ${which_sbatch} ${STUDY}

