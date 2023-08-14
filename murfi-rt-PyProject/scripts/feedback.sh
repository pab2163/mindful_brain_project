#! /bin/bash
# Clemens Bauer
# Modified by Paul Bloom December 2022


## 4 ARGS: [subid] [ses] [run] [step]

#Step 1: disable wireless internet, set MURFI_SUBJECTS_DIR, and NAMEcd
#Step 2: receive 2 volume scan
#Step 3: create masks
#Step 4: run murfi for realtime

subj=$1
step=$2
ses='ses-lo1'
run='run-01'

# Set initial paths
subj_dir=../subjects/$subj
cwd=$(pwd)
absolute_path=$(dirname $cwd)
subj_dir_absolute="${absolute_path}/subjects/$subj"
fsl_scripts=../scripts/fsl_scripts


# Set template files
template_dmn='DMNax_brainmaskero2_lps.nii.gz'
template_cen='CENa_brainmaskero2_lps.nii.gz'
SCRIPT_PATH=$(dirname $(realpath -s $0))
template_lps_path=${SCRIPT_PATH}/MNI152_T1_2mm_LPS_brain
#echo $template_lps_path

# Set paths & check that computers are properly connected with scanner via Ethernet
if [ ${step} = setup ]
then
    #clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ Wellcome to MURFI real-time Neurofeedback"
    echo "+ running " ${step}
    export MURFI_SUBJECTS_DIR="${absolute_path}/subjects/"
    export MURFI_SUBJECT_NAME=$subj
    echo "+ subject ID: "$MURFI_SUBJECT_NAME
    echo "+ working dir: $MURFI_SUBJECTS_DIR"
    #echo "disabling wireless internet"
    #ifdown wlan0
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "checking the presence of scanner and stim computer"
    ping -c 3 192.168.2.1
    ping -c 3 192.168.2.6
    echo "make sure Wi-Fi is off"
    echo "make sure you are Wired Connected to rt-fMRI"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
fi  

# run MURFI for 2vol scan (to be used for registering masks to native space)  
if [ ${step} = 2vol ]
then
    clear
    echo "ready to receive 2 volume scan"
    singularity exec murfi2.1.sif murfi -f $subj_dir/xml/2vol.xml
fi


if  [ ${step} = feedback ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ready to receive rtdmn feedback scan"
    export MURFI_SUBJECTS_DIR="${absolute_path}/subjects/"
    export MURFI_SUBJECT_NAME=$subj 
    singularity exec murfi2.1.sif murfi -f $subj_dir_absolute/xml/rtdmn.xml
fi


if  [ ${step} = resting_state ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ready to receive resting state scan"
    export MURFI_SUBJECTS_DIR="${absolute_path}/subjects/"
    export MURFI_SUBJECT_NAME=$subj
    singularity exec murfi2.1.sif murfi -f $subj_dir/xml/rest.xml

fi



if  [ ${step} = extract_rs_networks ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ compiling resting state run into analysis folder"

    expected_volumes=250
    runstring="Resting state runs should have ${expected_volumes} volumes\n"
    for i in {0..10};
    do
        # Find # of volumes in each run
        run_volumes=$(find ${subj_dir_absolute}/img/ -type f \( -iname "img-0000${i}*" \) | wc -l)
        if [ ${run_volumes} -ne 0 ]
        then
            runstring="${runstring}\nRun ${i}: ${run_volumes} volumes"
        fi
    done

    # use zenity to allow user to choose which resting volume to use (and how many runs to use)
    input_string=$(zenity --forms --title="Which resting state runs to use for ICA?" \
        --separator=" " --width 600 --height 600 \
        --add-entry="First Input Run #" \
        --add-entry="Second Input Run #" --text="`printf "${runstring}"`"\
        --add-combo="`printf "How many resting runs to use for ICA?\nOnly use runs that have 200+ volumes for ICA"`" --combo-values "2 (default) |1 (only to be used if there aren't 2 viable runs to use)")

    # check that exit button hasn't been clicked
    if [[ $? == 1 ]];
    then
        exit 0
    fi

    # parse zenity output using space as delimiter
    read -a input_array <<< $input_string
    rest_runA_num=${input_array[0]}
    rest_runB_num=${input_array[1]}

    # Use 2 resting runs for ICA
    echo ${input_array[2]}
    if [[ ${input_array[2]} == '2' ]] ;
    then
        echo "Using run ${rest_runA_num} and run ${rest_runB_num}"
        echo "Pre-processing images before ICA..."

        # merge individual volumes to make 1 file for each resting state run
        rest_runA_filename=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold.nii.gz'
        rest_runB_filename=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold.nii.gz' 

        # Merge all volumes in each run 
        volsA=$(find ${subj_dir_absolute}/img/ -type f \( -iname "img-0000${rest_runA_num}*" \))
        volsB=$(find ${subj_dir_absolute}/img/ -type f \( -iname "img-0000${rest_runB_num}*" \)) 
        fslmerge -tr $rest_runA_filename $volsA 1.2
        fslmerge -tr $rest_runB_filename $volsB 1.2

        # figure out how many volumes of resting state data there were to be used in ICA
        rest_runA_volumes=$(fslnvols $rest_runA_filename)
        rest_runB_volumes=$(fslnvols $rest_runB_filename)
        if [ ${rest_runA_volumes} -ne ${expected_volumes} ] || [ ${rest_runB_volumes} -ne ${expected_volumes} ]; 
        then
            echo "WARNING! ${rest_runA_volumes} volumes of resting-state data found for run 1."
            echo "${rest_runB_volumes} volumes of resting-state data found for run 2. ${expected_volumes} expected?"

            # calculate minimum volumes (which run has fewer, then use fslroi to cut both runs to this minimum)
            minvols=$(( rest_runA_volumes < rest_runB_volumes ? rest_runA_volumes : rest_runB_volumes ))
            echo "Clipping runs so that both have ${minvols} volumes"
            fslroi $rest_runA_filename $rest_runA_filename 0 $minvols
            fslroi $rest_runB_filename $rest_runB_filename 0 $minvols
        else
            minvols=$expected_volumes
        fi

        echo "+ computing resting state networks this will take about 25 minutes"
        echo "+ started at: $(date)"

        # realign volumes pre-FEAT
        mcflirt -in $rest_runA_filename -out $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt.nii.gz'
        mcflirt -in $rest_runB_filename -out $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt.nii.gz'

        # get median volume of 1st run
        fslmaths $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt.nii.gz' \
            -Tmedian $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz'

        # get median volume of 2st run
        fslmaths $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt.nii.gz' \
            -Tmedian $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt_median.nii.gz'
                
        # calculate registration matrix of median of 2nd run to median of 1st run
        flirt -cost leastsq -dof 6  -noresample -noresampblur \
            -in $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt_median.nii.gz' \
            -ref $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz' \
            -out $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run2_median_to_run1_median.nii.gz' \
            -omat $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run2_median_to_run1_median.mat' 


        # check registration of median of 2nd run to median of 1st run
        slices $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz' \
            $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run2_median_to_run1_median.nii.gz' \
            -o $subj_dir_absolute/qc/flirt_median_rest_check.gif 

        # use registration matrix previously calculated to warp entire 2nd run to median of 1st run
        flirt -noresample -noresampblur -interp nearestneighbour \
            -in  $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt.nii.gz' \
            -ref $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz'  \
            -out $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt_run1space.nii.gz' \
            -init $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run2_median_to_run1_median.mat' \
            -applyxfm

        # skullstrip median of 1st run & check the generated mask
        bet $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz' \
            $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet.nii.gz' \
            -R -f 0.4 -g 0 -m 

        slices $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz' \
            $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet.nii.gz' \
            -o $subj_dir_absolute/qc/rest_skullstrip_check_run1.gif

        # mask both runs by the mask from skullstriped median of 1st run
        fslmaths $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt.nii.gz' \
            -mas $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet_mask.nii.gz' \
            $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_masked.nii.gz'

        fslmaths $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt_run1space.nii.gz' \
            -mas $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet_mask.nii.gz' \
            $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt_run1space_masked.nii.gz'


        
        ica_run1_input=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_masked.nii.gz'
        ica_run2_input=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-02_bold_mcflirt_run1space_masked.nii.gz'
        reference_vol_for_ica=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet.nii.gz'

        # update FEAT template with paths and # of volumes of resting state run
        cp $fsl_scripts/basic_ica_template.fsf $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        OUTPUT_dir=$subj_dir_absolute/rest/rs_network
        sed -i "s#DATA1#$ica_run1_input#g" $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        sed -i "s#DATA2#$ica_run2_input#g" $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        sed -i "s#OUTPUT#$OUTPUT_dir#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        sed -i "s#REFERENCE_VOL#$reference_vol_for_ica#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf 

        # update fsf to match number of rest volumes
        sed -i "s/set fmri(npts) 250/set fmri(npts) ${minvols}/g" $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        feat $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf        
    else
        # Use just a single run for ICA (only to be used when 2 isn't viable)
        echo "Using run ${rest_runA_num} for single-run ICA"

        # merge individual volumes to make 1 file for each resting state run
        rest_runA_filename=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold'.nii.gz
        volsA=$(find ${subj_dir_absolute}/img/ -type f \( -iname "img-0000${rest_runA_num}*" \))
        fslmerge -tr $rest_runA_filename $volsA 1.2

        # figure out how many volumes of resting state data there were to be used in ICA
        rest_runA_volumes=$(fslnvols $rest_runA_filename)
        echo "${rest_runA_volumes} volumes of resting-state data found for run 1."
        echo "+ computing resting state networks this will take about 25 minutes"
        echo "+ started at: $(date)"

         # realign volumes pre-FEAT
        mcflirt -in $rest_runA_filename -out $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt.nii.gz'

        # get median volume of 1st run
        fslmaths $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt.nii.gz' \
            -Tmedian $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz'
     
        # skullstrip median of 1st run & check the generated mask
        bet $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz' \
            $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet.nii.gz' \
            -R -f 0.4 -g 0 -m 

        slices $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median.nii.gz' \
            $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet.nii.gz' \
            -o $subj_dir_absolute/qc/rest_skullstrip_check_run1.gif

        # mask run1 by the mask from skullstriped median of 1st run
        fslmaths $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt.nii.gz' \
            -mas $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet_mask.nii.gz' \
            $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_masked.nii.gz'
        
        ica_run1_input=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_masked.nii.gz'
        reference_vol_for_ica=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet.nii.gz'

        # update FEAT template with paths and # of volumes of resting state run
        cp fsl_scripts/basic_ica_template_single_run.fsf $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        OUTPUT_dir=$subj_dir_absolute/rest/rs_network
        sed -i "s#DATA#$ica_run1_input#g" $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        sed -i "s#OUTPUT#$OUTPUT_dir#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        sed -i "s#REFERENCE_VOL#$reference_vol_for_ica#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf 

        # update fsf to match number of rest volumes
        sed -i "s/set fmri(npts) 250/set fmri(npts) ${rest_runA_volumes}/g" $subj_dir_absolute/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
        feat $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf   
    fi                        
fi


if [ ${step} = process_roi_masks ]
then
    clear
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        echo "+ Generating DMN & CEN Masks "
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        

    # Set up file paths needed for mask creation
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
    echo "ICA is: ${ica_version}"


    # Make output file to store correlations with template networks
    correlfile=$ica_directory/template_rsn_correlations_with_ICs.txt
    touch ${correlfile}
    template_networks='template_networks.nii.gz'


    # If single-session, then ICA was done in native space, and registration is needed
    if [ $ica_version == 'single_run' ]
    then
        # ICs in native space
        infile=$ica_directory/filtered_func_data.ica/melodic_IC.nii.gz 

    else # Multi run
        # ICs in "template" space - template is median of first resting state run used in ICA
        infile=$ica_directory/melodic_IC
        mkdir -p ${ica_directory}/reg
    fi

    # Create filepaths for registration files
    examplefunc=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet.nii.gz'
    examplefunc_mask=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet_mask.nii.gz'
    #standard=${ica_directory}/reg/standard.nii.gz
    example_func2mni_lps_mat=${ica_directory}/reg/example_func2mni_lps.mat
    example_func2mni_lps=${ica_directory}/reg/example_func2mni_lps
    mni_lps2xample_func=${ica_directory}/reg/mni_lps2example_func.nii.gz
    mni_lps2example_func_mat=${ica_directory}/reg/mni_lps2example_func.mat

    # Register example func to LPS MNI template, then calculate inverse
    # This registration will be used to bring template networks to native space
    flirt -in ${examplefunc} -ref MNI152_T1_2mm_LPS_brain -out ${example_func2mni_lps} -omat ${example_func2mni_lps_mat}
    convert_xfm -omat ${mni_lps2example_func_mat} -inverse ${example_func2mni_lps_mat}


    # Set paths for files needed for the next few steps 
    ## Unthresholded masks in native space
    dmn_uthresh=$ica_directory/dmn_uthresh.nii.gz
    cen_uthresh=$ica_directory/cen_uthresh.nii.gz

    ## Paths for registration files
    template2example_func=${ica_directory}/reg/template_networks2example_func.nii.gz
    dmn2example_func=${ica_directory}/reg/template_dmn2example_func.nii.gz
    cen2example_func=${ica_directory}/reg/template_cen2example_func.nii.gz


    # WARP LPS MNI brain template to resting-state run native space
    flirt -in MNI152_T1_2mm_LPS_brain -ref ${examplefunc} -out ${mni_lps2xample_func} -init ${mni_lps2example_func_mat} -applyxfm
    
    # Register the networks from template (MNI LPS) space into resting-state run native space
    flirt -in ${template_networks} -ref ${examplefunc} -out ${template2example_func} -init ${mni_lps2example_func_mat} -applyxfm
    flirt -in ${template_dmn} -ref ${examplefunc} -out ${dmn2example_func} -init ${mni_lps2example_func_mat} -applyxfm
    flirt -in ${template_cen} -ref ${examplefunc} -out ${cen2example_func} -init ${mni_lps2example_func_mat} -applyxfm


    # Correlate (spatially) ICA components (not thresholded) with DMN & CEN template files
    rm -f ${correlfile}
    fslcc --noabs -p 8 -t -1 -m ${examplefunc_mask} ${infile} ${template2example_func}>>${correlfile}

    # Split ICs to separate files
    split_outfile=$ica_directory/melodic_IC_
    fslsplit ${infile} ${split_outfile}

    # Selection of ICs most highly correlated with template networks
    python rsn_get.py ${subj} ${ica_version}

    ## Thresholded masks in MNI space
    dmn_thresh=$ica_directory/dmn_thresh.nii.gz
    cen_thresh=$ica_directory/cen_thresh.nii.gz


    # Hard code the number of voxels desired for each mask
    num_voxels_desired=2000

    # zero out voxels not included in the template masks (i.e. so we only select voxels within template DMN/CEN)
    fslmaths ${dmn_uthresh} -mul ${dmn2example_func} ${dmn_uthresh}
    fslmaths ${cen_uthresh} -mul ${cen2example_func} ${cen_uthresh}


    # get number of non-zero voxels in masks, calculate percentile cutofff needed for the desired absolute number of voxels
    voxels_in_dmn=$(fslstats ${dmn_uthresh} -V | awk '{print $1}')
    percentile_dmn=$(python -c "print(100*(1-${num_voxels_desired}/${voxels_in_dmn}))")
    voxels_in_cen=$(fslstats ${cen_uthresh} -V | awk '{print $1}')
    percentile_cen=$(python -c "print(100*(1-${num_voxels_desired}/${voxels_in_cen}))")


    # get threshold based on percentile
    dmn_thresh_value=$(fslstats ${dmn_uthresh} -P ${percentile_dmn})
    cen_thresh_value=$(fslstats ${cen_uthresh} -P ${percentile_cen})

    # threshold masks 
    fslmaths ${dmn_uthresh} -thr ${dmn_thresh_value} -bin ${dmn_thresh} -odt short
    fslmaths ${cen_uthresh} -thr ${cen_thresh_value} -bin ${cen_thresh} -odt short

    echo "Number of voxels in dmn mask: $(fslstats ${dmn_thresh} -V | head -c 5)"
    echo "Number of voxels in cen mask: $(fslstats ${cen_thresh} -V | head -c 5)"

    # copy masks to participant's mask directory
    cp ${dmn_thresh} ${subj_dir}/mask/dmn_native_rest.nii.gz
    cp ${cen_thresh} ${subj_dir}/mask/cen_native_rest.nii.gz


    # Display masks with FSLEYES
    if [ $ica_version == 'single_run' ]
    then
        fsleyes $examplefunc ${mni_lps2xample_func} ${dmn_thresh} -cm blue ${cen_thresh} -cm red
    else
        fsleyes $examplefunc ${mni_lps2xample_func} ${dmn_thresh} -cm blue ${cen_thresh} -cm red
    fi

fi

# For registering masks in resting state space to 2vol space
if [ ${step} = register ]
then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "Registering masks to study_ref"
    latest_ref=$(ls -t $subj_dir/xfm/series*.nii | head -n1)
    latest_ref="${latest_ref::-4}"
    study_ref=${subj_dir}/xfm/study_ref.nii

    # if localizer_ref images doesn't exist yet, make it
    if [ ! -f ${subj_dir}/xfm/localizer_ref.nii ]
    then
        mv ${study_ref} ${subj_dir}/xfm/localizer_ref.nii
    fi
    echo "Registering masks to reference image from most recent series: ${latest_ref}"
    echo "study_ref.nii is now ${latest_ref}"

    # Move the latest reference image to be study_ref
    # study_ref.nii is used by MURFI to register to 1st volume of feedback runs
    # So ROI masks need to be in the same space as study_ref.nii
    cp ${latest_ref}.nii ${study_ref}

    bet ${latest_ref} ${latest_ref}_brain -R -f 0.4 -g 0 -m # changed from -f 0.6
    slices ${latest_ref} ${latest_ref}_brain_mask -o $subj_dir/qc/2vol_skullstrip_brain_mask_check.gif

    rm -r $subj_dir/xfm/epi2reg
    mkdir -p $subj_dir/xfm/epi2reg

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
    
    # # warp masks in RESTING STATE ICA SPACE (median of rest run1) into 2VOL native space (studyref)
    examplefunc=$subj_dir_absolute/rest/$subj'_'$ses'_task-rest_run-01_bold_mcflirt_median_bet.nii.gz'
    flirt -in $examplefunc -ref ${latest_ref}_brain -out $subj_dir/xfm/epi2reg/rest2studyref_brain -omat $subj_dir/xfm/epi2reg/rest2studyref.mat

    # make registration image for inspection, and open it
    slices $subj_dir/xfm/epi2reg/rest2studyref_brain ${latest_ref}_brain -o $subj_dir/qc/rest_warp_to_2vol_native_check.gif

    # If paths to personalized masks exist, then run MURFI. Otherwise, prompt user about whether to use template masks instead
    dmn_thresh="../subjects/${subj}/mask/dmn_native_rest.nii.gz"
    cen_thresh="../subjects/${subj}/mask/cen_native_rest.nii.gz"   

    # For each mask (REST native space), swap register to 2vol native space
    # Everything should  be LPS here
    for mask_name in {'dmn','cen'};
    do 
        echo "+ REGISTERING ${mask_name} TO study_ref" 

        # warp masks from resting state space to 2vol space
        flirt -in $subj_dir/mask/${mask_name}_native_rest.nii.gz -ref ${latest_ref} -out $subj_dir/mask/${mask_name} -init $subj_dir/xfm/epi2reg/rest2studyref.mat -applyxfm -interp nearestneighbour -datatype short
        
        # erode 2vvol brain mask one voxel
        fslmaths ${latest_ref}_brain_mask -ero ${latest_ref}_brain_mask_ero1

        # binarize masks based on eroded 2vol brain mask
        fslmaths $subj_dir/mask/${mask_name}.nii.gz -mul ${latest_ref}_brain_mask_ero1 $subj_dir/mask/${mask_name}.nii.gz -odt short


        gunzip -f $subj_dir/mask/${mask_name}.nii.gz
    done

    echo "+ INSPECT"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    xdg-open $subj_dir/qc/rest_warp_to_2vol_native_check.gif
    fsleyes ${latest_ref}_brain  $subj_dir/xfm/epi2reg/rest2studyref_brain $subj_dir/mask/cen.nii -cm red $subj_dir/mask/dmn.nii -cm blue  #$subj_dir/mask/smc.nii -cm yellow $subj_dir/mask/stg.nii -cm green
fi



if [ ${step} = cleanup ]
then
    input_string=$(zenity --forms --title="Delete files?" \
    --separator=" " \
    --text="`printf "Are you sure you want to clean up the directory and delete files for ${subj}?\nThe entire img folder will be deleted, as well as raw bold data from the rest directory"`" \
    --cancel-label "Exit" --ok-label "Delete files")
    ret=$?

    # If user selects the Exit button, then quit MURFI
    if [[ $ret == 1 ]];
    then
        exit 0
    fi

    # Delete img folder and large bold files from the rest folder
    rm -rf $subj_dir/img
    rm -f $subj_dir/rest/*bold.nii.gz
    rm -f $subj_dir/rest/*bold_mcflirt.nii.gz
    rm -f $subj_dir/rest/*bold_mcflirt_masked.nii.gz
fi


# ONLY if regular mask generation isn't possible
# As a backup, we can register the template masks to 2vol space
if [ ${step} = backup_reg_mni_masks_to_2vol ]
then
    clear
    mni_template=MNI152_T1_2mm_LPS_brain.nii.gz
    dmn_mni=DMNax_brainmaskero2_lps.nii.gz
    cen_mni=CENa_brainmaskero2_lps.nii.gz

    two_vol_ref=$(ls -t $subj_dir/xfm/series*.nii | head -n1)
    two_vol_ref="${two_vol_ref::-4}"

    two_vol_ref_bet=${subj_dir}/xfm/two_vol_ref_bet.nii.gz
    two_vol_ref2mni=${subj_dir}/xfm/two_vol_ref2mni.nii.gz
    two_vol_ref2mni_mat=${subj_dir}/xfm/two_vol_ref2mni.mat
    mni2_two_vol_ref_mat=${subj_dir}/xfm/mni2_two_vol_ref.mat

    study_ref=${subj_dir}/xfm/study_ref.nii
    # if localizer_ref images doesn't exist yet, make it
    if [ ! -f ${subj_dir}/xfm/localizer_ref.nii ]
    then
        mv ${study_ref} ${subj_dir}/xfm/localizer_ref.nii
    fi
    echo "Registering masks to reference image from most recent series: ${two_vol_ref}"
    echo "study_ref.nii is now ${two_vol_ref}"

    # Move the latest reference image to be study_ref
    # study_ref.nii is used by MURFI to register to 1st volume of feedback runs
    # So ROI masks need to be in the same space as study_ref.nii
    cp ${two_vol_ref}.nii ${study_ref}


    # skullstrip 2vol before registration
    bet ${two_vol_ref} ${two_vol_ref_bet} -R -f 0.4 -g 0 -m # changed from -f 0.6


    # first, register the 2vol to mni
    # then calculate the inverse of the registration
    flirt -in ${two_vol_ref_bet} -ref ${mni_template} -out ${two_vol_ref2mni} -omat ${two_vol_ref2mni_mat}
    convert_xfm -omat ${mni2_two_vol_ref_mat} -inverse ${two_vol_ref2mni_mat}


    # "apply" the inverse of the registration to dmn/cen masks
    #put them in the participant mask folder

    #DMN
    flirt -in ${dmn_mni} -ref ${two_vol_ref_bet} -out $subj_dir/mask/dmn.nii -init ${mni2_two_vol_ref_mat} -applyxfm -interp nearestneighbour -datatype short

    #CEN
    flirt -in ${cen_mni} -ref ${two_vol_ref_bet} -out $subj_dir/mask/cen.nii -init ${mni2_two_vol_ref_mat} -applyxfm -interp nearestneighbour -datatype short

fi