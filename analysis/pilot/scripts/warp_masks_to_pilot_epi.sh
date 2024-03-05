bet ../data/img-00001-00001_2std.nii ../data/img-00001-00001_brain.nii

#calculate registration matrix
flirt \
    -in ../../../murfi-rt-PyProject/scripts/MNI152_T1_2mm_brain.nii.gz \
    -ref ../data/img-00001-00001_brain.nii \
    -out  ../data/mni2pilot_epi.nii.gz \
    -omat ../data/mni2pilot_epi.mat 

# use registration matrix previously calculated to warp dmn and fpn masks
flirt -noresample -noresampblur -interp nearestneighbour \
    -in  ../data/sub-rtBANDA073_dmn_mask.nii.gz \
    -ref ../data/img-00001-00001_brain.nii  \
    -out ../data/sub-rtBANDA073_dmn_mask_2epi_space.nii \
    -init ../data/mni2pilot_epi.mat \
    -applyxfm

flirt -noresample -noresampblur -interp nearestneighbour \
    -in  ../data/sub-rtBANDA073_cen_mask.nii.gz \
    -ref ../data/img-00001-00001_brain.nii  \
    -out ../data/sub-rtBANDA073_cen_mask_2epi_space.nii \
    -init ../data/mni2pilot_epi.mat \
    -applyxfm   