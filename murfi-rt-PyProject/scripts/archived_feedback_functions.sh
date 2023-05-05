# For registering masks in MNI space to native space (based on 2vol scan)
if [ ${step} = register ]
then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "Registering masks to study_ref"
    echo "Ignore Flipping WARNINGS we need LPS/NEUROLOGICAL orientation for murfi feedback!!"
    latest_ref=$(ls -t $subj_dir/xfm/*.nii | head -n1)
    latest_ref="${latest_ref::-4}"
    echo ${latest_ref}
    bet ${latest_ref} ${latest_ref}_brain -R -f 0.4 -g 0 -m # changed from -f 0.6
    slices ${latest_ref} ${latest_ref}_brain_mask  -o $subj_dir/qc/register1_bet_2vol_skullstrip_check.gif #DP UPDATE 4/12/23

    # CCCB version (direct flirt from subject functional to MNI structural: step 1)
    # because the images that we get from Prisma through Vsend are in LPS orientation we need to change both our MNI mean image and our mni masks accordingly: 
    #fslswapdim MNI152_T1_2mm.nii.gz x -y z MNI152_T1_2mm_LPS.nii.gz
    #fslorient -forceneurological MNI152_T1_2mm_LPS.nii.gz
    # once the images are in the same orientation we can do registration
    rm -r $subj_dir/xfm/epi2reg
    mkdir $subj_dir/xfm/epi2reg
    mkdir $subj_dir/mask/lps

    # warp MNI templates into native space
    flirt -in MNI152_T1_2mm_LPS.nii.gz -ref ${latest_ref} -out $subj_dir/xfm/epi2reg/mnilps2studyref -omat $subj_dir/xfm/epi2reg/mnilps2studyref.mat
    flirt -in MNI152_T1_2mm_LPS_brain.nii.gz -ref ${latest_ref}_brain -out $subj_dir/xfm/epi2reg/mnilps2studyref_brain -omat $subj_dir/xfm/epi2reg/mnilps2studyref.mat

    # make registration image for inspection, and open it
    slices $subj_dir/xfm/epi2reg/mnilps2studyref_brain ${latest_ref}_brain -o $subj_dir/qc/register2_flirt_MNI2_warp_to_2vol_native_check.gif #DP UPDATE name 4/12/23

    # If paths to personalized masks exist, then run MURFI. Otherwise, prompt user about whether to use template masks instead
    dmn_mni_thresh="../subjects/${subj}/mask/mni/dmn_mni.nii.gz"
    cen_mni_thresh="../subjects/${subj}/mask/mni/cen_mni.nii.gz"   
    if [ -f "${dmn_mni_thresh}" ] && [ -f "${cen_mni_thresh}" ];
    then
        echo 'Found DMN & CEN MNI masks'
    else 
        # If the user wants, use standard DMN & CEN templates for feedback
        if zenity --question --text="Continue using standard DMN &amp; CEN templates instead?" \
            --width=800 --title="Warning, no masks found for ${subj}!"
        then
            cp $template_dmn $dmn_mni_thresh
            cp $template_cen $cen_mni_thresh
        else
            exit 0
        fi
    fi

    # For each mask (MNI), swap dimension & register to 2vol native space
    for mask_name in {dmn,cen};
    do 
        echo "+ REGISTERING ${mask_name} TO study_ref" 
        #fslswapdim $subj_dir/mask/mni/${mask_name}_mni x -y z $subj_dir/mask/lps/${mask_name}_mni_lps
        #fslorient -forceneurological $subj_dir/mask/lps/${mask_name}_mni_lps
        
        #start registration
        flirt -in $subj_dir/mask/lps/${mask_name}_mni_lps -ref ${latest_ref} -out $subj_dir/mask/${mask_name} -init $subj_dir/xfm/epi2reg/mnilps2studyref.mat -applyxfm -interp nearestneighbour -datatype short
        fslmaths $subj_dir/mask/${mask_name}.nii.gz -mul ${latest_ref}_brain_mask $subj_dir/mask/${mask_name}.nii.gz -odt short

        # erode each mask one voxel
        #fslmaths $subj_dir/mask/${mask_name}.nii.gz -ero $subj_dir/mask/${mask_name}.nii.gz 
        gunzip -f $subj_dir/mask/${mask_name}.nii.gz
    done

    echo "+ INSPECT"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    xdg-open $subj_dir/xfm/MNI2_warp_to_2vol_native_check.gif
    fsleyes ${latest_ref}_brain  $subj_dir/mask/cen.nii -cm red $subj_dir/mask/dmn.nii -cm blue  #$subj_dir/mask/smc.nii -cm yellow $subj_dir/mask/stg.nii -cm green
fi

if [ ${step} = process_roi_masks ]
then
clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ Generating DMN & CEN Masks "
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    

# Set up file paths needed for mask creation

## File to contain spatial correlations between ICs & template networks

# first look for ICA feat directory based on multiple runs (.gica directory)
ica_directory=$subj_dir/rest/rs_network.gica/groupmelodic.ica/

if [ -d $ica_directory ]
then
    ica_version='multi_run'

# if ICA feat dir for multi-run ICA isn't present, look for single-run version
elif [ -d "${subj_dir}/rest/rs_network.ica/filtered_func_data.ica/" ] 
then
    ica_directory="${subj_dir}/rest/rs_network.ica/" 
    ica_version='single_run'
else
    echo "Error: no ICA directory found for ${subj}. Exiting now..."
    exit 0
fi
correlfile=${ica_directory}/template_rsn_correlations_with_ICs.txt
touch ${correlfile}

template_networks='template_networks.nii.gz'

# Merge template files to 1 image
#fslmerge -tr ${template_networks} ${template_dmn} ${template_cen} 1 # DP don't need to run every time?

echo $ica_version



# If single-session, then ICA was done in native space, and registration is needed
if [ $ica_version == 'single_run' ]
then
    # ICs in native space
    infile=$ica_directory/filtered_func_data.ica/melodic_IC.nii.gz 
    # ICA file, template, and transform matrices needed for registration
    examplefunc=${ica_directory}/reg/example_func.nii.gz
    standard=${ica_directory}/reg/standard.nii.gz
    example_func2standard_mat=${ica_directory}/reg/example_func2standard.mat
    standard2example_func_mat=${ica_directory}/reg/standard2example_func.mat

    # Warp template to native space (based on the resting state data used for ICA)
    template2example_func=${ica_directory}/reg/template_networks2example_func.nii.gz
    flirt -in ${template_networks} -ref ${examplefunc} -out ${template2example_func} -init ${standard2example_func_mat} -applyxfm

    # Set paths for files needed for the next few steps 
    ## Unthresholded masks in native space
    dmn_uthresh=$ica_directory/dmn_uthresh.nii.gz
    cen_uthresh=$ica_directory/cen_uthresh.nii.gz

    # Correlate (spatially) ICA components (not thresholded) with DMN & CEN template files
    fslcc --noabs -p 3 -t -1 ${infile} ${template2example_func} >>${correlfile}
else
    # ICs in template space
    infile=$ica_directory/melodic_IC.nii.gz 
    # Correlate (spatially) ICA components (not thresholded) with DMN & CEN template files
    fslcc --noabs -p 3 -t -1 ${infile} ${template_networks} >>${correlfile}
fi



# Split ICs to separate files
split_outfile=$ica_directory/melodic_IC_
fslsplit ${infile} ${split_outfile}

# Selection of ICs most highly correlated with template networks
python rsn_get.py ${subj} ${ica_version}


## Unthresholded masks in mni space
dmn_mni_uthresh=$ica_directory/dmn_mni_uthresh.nii.gz
cen_mni_uthresh=$ica_directory/cen_mni_uthresh.nii.gz

## Thresholded masks in MNI space
dmn_mni_thresh=$ica_directory/dmn_mni_thresh.nii.gz
cen_mni_thresh=$ica_directory/cen_mni_thresh.nii.gz


# Hard code the number of voxels desired for each mask
num_voxels_desired=2000

# If single-run ICA, register non-thresholded masks to MNI space
if [ $ica_version == 'single_run' ]
then
    flirt -in  ${dmn_uthresh} -ref ${standard} -out ${dmn_mni_uthresh} -init ${example_func2standard_mat} -applyxfm
    flirt -in  ${cen_uthresh} -ref ${standard} -out ${cen_mni_uthresh} -init ${example_func2standard_mat} -applyxfm
fi

# Everything from here to the end of this step is in template space

# zero out voxels not included in the template masks (i.e. so we only select voxels within template DMN/CEN)
fslmaths ${dmn_mni_uthresh} -mul ${template_dmn} ${dmn_mni_uthresh}
fslmaths ${cen_mni_uthresh} -mul ${template_cen} ${cen_mni_uthresh}


# get number of non-zero voxels in masks, calculate percentile cutofff needed for the desired absolute number of voxels
voxels_in_dmn=$(fslstats ${dmn_mni_uthresh} -V | awk '{print $1}')
percentile_dmn=$(python -c "print(100*(1-${num_voxels_desired}/${voxels_in_dmn}))")
voxels_in_cen=$(fslstats ${cen_mni_uthresh} -V | awk '{print $1}')
percentile_cen=$(python -c "print(100*(1-${num_voxels_desired}/${voxels_in_cen}))")


# get threshold based on percentile
dmn_thresh_value=$(fslstats ${dmn_mni_uthresh} -P ${percentile_dmn})
cen_thresh_value=$(fslstats ${cen_mni_uthresh} -P ${percentile_cen})

# threshold masks in MNI space
fslmaths ${dmn_mni_uthresh} -thr ${dmn_thresh_value} -bin ${dmn_mni_thresh} -odt short
fslmaths ${cen_mni_uthresh} -thr ${cen_thresh_value} -bin ${cen_mni_thresh} -odt short

echo "Number of voxels in dmn mask: $(fslstats ${dmn_mni_thresh} -V)"
echo "Number of voxels in cen mask: $(fslstats ${cen_mni_thresh} -V)"

# copy masks to participant's mask directory
cp ${dmn_mni_thresh} ${subj_dir}/mask/mni/dmn_mni.nii.gz
cp ${cen_mni_thresh} ${subj_dir}/mask/mni/cen_mni.nii.gz


# Display masks with FSLEYES
fsleyes  mean_brain.nii.gz ${dmn_mni_thresh} -cm blue ${cen_mni_thresh} -cm red

fi