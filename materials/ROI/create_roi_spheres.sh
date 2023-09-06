# MNI coordinates -1, 53, -3
3dcalc -a ../../murfi-rt-PyProject/scripts/MNI152_T1_2mm_brain.nii.gz  -expr 'step(64-(x-1)*(x-1)-(y+53)*(y+53)-(z+3)*(z+3))' -prefix mpfc_sphere_8mm

# MNI coordinates 2, -60, 38
3dcalc -a ../../murfi-rt-PyProject/scripts/MNI152_T1_2mm_brain.nii.gz  -expr 'step(64-(x+2)*(x+2)-(y-60)*(y-60)-(z-38)*(z-38))' -prefix pcc_sphere_8mm

# MNI coordinates 2, -60, 36
3dcalc -a ../../murfi-rt-PyProject/scripts/MNI152_T1_2mm_brain.nii.gz  -expr 'step(64-(x+2)*(x+2)-(y-60)*(y-60)-(z-36)*(z-36))' -prefix pcc_sphere_cog_8mm

# Convert to .nii
3dAFNItoNIFTI mpfc_sphere_8mm+tlrc.BRIK -prefix mpfc_sphere_8mm.nii
3dAFNItoNIFTI pcc_sphere_8mm+tlrc.BRIK -prefix pcc_sphere_8mm.nii
3dAFNItoNIFTI pcc_sphere_cog_8mm+tlrc.BRIK -prefix pcc_sphere_cog_8mm.nii


rm *.BRIK
rm *.HEAD