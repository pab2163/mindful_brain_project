#! /bin/bash
# Clemens Bauer

# Set initial paths
cwd=$(pwd)

scan=${1}

#for dicom transfer
#singularity exec murfi-sif_latest.sif servedicoms img/dcm/feedback/ tmp/murfi_input 1200
#for vsend
singularity exec /home/rt/singularity-images/murfi-sif_latest.sif servenii4d img/${scan} $(hostname)
