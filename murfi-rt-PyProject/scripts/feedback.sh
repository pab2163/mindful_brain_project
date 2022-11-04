#! /bin/bash

##Input taken: subject_ID, Step#, roi, run##

#Step 1: disable wireless internet, set MURFI_SUBJECTS_DIR, and NAMEcd
#Step 2: receive 2 volume scan
#Step 3: create masks
#Step 4: run murfi for realtime

subj=$1
ses=$2
run=$3
step=$4

subj_dir=../subjects/$subj
#subject_data_dir=../data/${subj}/ses-localizer/func/
fsl_scripts=../scripts/fsl_scripts
if [ ${step} = setup ]
then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ Wellcome to MURFI real-time Neurofeedback"
    echo "+ running " ${step}
    export MURFI_SUBJECTS_DIR=../subjects/
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
  
if [ ${step} = 2vol ]
then
    clear
    echo "ready to receive 2 volume scan"
    singularity exec /home/auerbachlinux/singularity-images/murfi2.sif murfi -f $subj_dir/xml/2vol.xml
fi


 #this step is no longer needed since we are processing everything in subjectspace, see localizer.sh
if [ ${step} = register ]
then
    clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "Registering masks to study_ref"
    echo "Ignore Flipping WARNINGS we need LPS/NEUROLOGICAL orientation for murfi feedback!!"
    latest_ref=$(ls -t $subj_dir/xfm/*.nii | head -n1)
    latest_ref="${latest_ref::-4}"
    echo ${latest_ref}
    bet ${latest_ref} ${latest_ref}_brain -R -f 0.6 -g 0 -m

    # CCCB version (direct flirt from subject functional to MNI structural: step 1)
    # because the images that we get from Prisma through Vsend are in LPS orientation we need to change both our MNI mean image and our mni masks accordingly: 
   fslswapdim MNI152_T1_2mm.nii.gz x -y z MNI152_T1_2mm_LPS.nii.gz
   fslorient -forceneurological MNI152_T1_2mm_LPS.nii.gz
#   once the images are in the same orientation we can do registration
    rm -r $subj_dir/xfm/epi2reg
    mkdir $subj_dir/xfm/epi2reg
    mkdir $subj_dir/mask/lps

#for mni_mask in {dmn,cen,smc}; #include this for DMN feedback
    for mni_mask in {dmn,cen,smc,stg};do 
        echo "+ REGISTERING ${mni_mask} TO study_ref" 
    flirt -in MNI152_T1_2mm_LPS.nii.gz -ref ${latest_ref} -out $subj_dir/xfm/epi2reg/mnilps2studyref -omat $subj_dir/xfm/epi2reg/mnilps2studyref.mat
    flirt -in MNI152_T1_2mm_LPS_brain.nii.gz -ref ${latest_ref}_brain -out $subj_dir/xfm/epi2reg/mnilps2studyref_brain -omat $subj_dir/xfm/epi2reg/mnilps2studyref.mat

    fslswapdim $subj_dir/mask/mni/${mni_mask}_mni x -y z $subj_dir/mask/lps/${mni_mask}_mni_lps
       fslorient -forceneurological $subj_dir/mask/lps/${mni_mask}_mni_lps
    #start registration

      flirt -in $subj_dir/mask/lps/${mni_mask}_mni_lps -ref ${latest_ref} -out $subj_dir/mask/${mni_mask} -init $subj_dir/xfm/epi2reg/mnilps2studyref.mat -applyxfm -interp nearestneighbour -datatype short
	fslmaths $subj_dir/mask/${mni_mask}.nii.gz -mul ${latest_ref}_brain_mask $subj_dir/mask/${mni_mask}.nii.gz -odt short
	gunzip -f $subj_dir/mask/${mni_mask}.nii.gz;done
        #rm $subj_dir/mask/${mni_mask}.nii.gz
     
    
    #cp $subj_dir/mask/dmn.nii $subj_dir/mask/non.nii
    echo "+ INSPECT"
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    fsleyes ${latest_ref}_brain  $subj_dir/mask/stg.nii -cm green $subj_dir/mask/cen.nii -cm red $subj_dir/mask/dmn.nii -cm blue  $subj_dir/mask/smc.nii -cm yellow
fi

if [ ${step} = nf ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ready to receive stg feedback scan"
    singularity exec /home/auerbachlinux/singularity-images/murfi2.sif murfi -f $subj_dir/xml/$subj_$run.xml
fi

if  [ ${step} = feedback ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ready to receive rtdmn feedback scan"
    singularity exec /home/auerbachlinux/singularity-images/murfi2.sif murfi -f $subj_dir/xml/rtdmn.xml
fi

if  [ ${step} = smc ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ready to receive smc feedback scan"
    singularity exec /home/auerbachlinux/singularity-images/murfi2.sif murfi -f $subj_dir/xml/$subj_$run.xml
fi

if  [ ${step} = resting_state ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "ready to receive resting state scan"
    singularity exec /home/auerbachlinux/singularity-images/murfi2.sif murfi -f $subj_dir/xml/rest.xml
fi



if  [ ${step} = extract_rs_networks ]
then
clear
    echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ compiling resting state run into analysis folder"
    cp ../scripts/img/img-00001-00002.nii  $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii
    yes n | gzip $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii

    fslmerge -tr $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii.gz ../scripts/img/img-00001-00002.nii ../scripts/img/img-00001-00003.nii ../scripts/img/img-00001-00004.nii ../scripts/img/img-00001-00005.nii ../scripts/img/img-00001-00006.nii ../scripts/img/img-00001-00007.nii ../scripts/img/img-00001-00008.nii ../scripts/img/img-00001-00009.nii ../scripts/img/img-00001-00010.nii ../scripts/img/img-00001-00011.nii ../scripts/img/img-00001-00012.nii ../scripts/img/img-00001-00013.nii ../scripts/img/img-00001-00014.nii ../scripts/img/img-00001-00015.nii ../scripts/img/img-00001-00016.nii ../scripts/img/img-00001-00017.nii ../scripts/img/img-00001-00018.nii ../scripts/img/img-00001-00019.nii ../scripts/img/img-00001-00020.nii ../scripts/img/img-00001-00021.nii ../scripts/img/img-00001-00022.nii ../scripts/img/img-00001-00023.nii ../scripts/img/img-00001-00024.nii ../scripts/img/img-00001-00025.nii ../scripts/img/img-00001-00026.nii ../scripts/img/img-00001-00027.nii ../scripts/img/img-00001-00028.nii ../scripts/img/img-00001-00029.nii ../scripts/img/img-00001-00030.nii ../scripts/img/img-00001-00031.nii ../scripts/img/img-00001-00032.nii ../scripts/img/img-00001-00033.nii ../scripts/img/img-00001-00034.nii ../scripts/img/img-00001-00035.nii ../scripts/img/img-00001-00036.nii ../scripts/img/img-00001-00037.nii ../scripts/img/img-00001-00038.nii ../scripts/img/img-00001-00039.nii ../scripts/img/img-00001-00040.nii ../scripts/img/img-00001-00041.nii ../scripts/img/img-00001-00042.nii ../scripts/img/img-00001-00043.nii ../scripts/img/img-00001-00044.nii ../scripts/img/img-00001-00045.nii ../scripts/img/img-00001-00046.nii ../scripts/img/img-00001-00047.nii ../scripts/img/img-00001-00048.nii ../scripts/img/img-00001-00049.nii ../scripts/img/img-00001-00050.nii ../scripts/img/img-00001-00051.nii ../scripts/img/img-00001-00052.nii ../scripts/img/img-00001-00053.nii ../scripts/img/img-00001-00054.nii ../scripts/img/img-00001-00055.nii ../scripts/img/img-00001-00056.nii ../scripts/img/img-00001-00057.nii ../scripts/img/img-00001-00058.nii ../scripts/img/img-00001-00059.nii ../scripts/img/img-00001-00060.nii ../scripts/img/img-00001-00061.nii ../scripts/img/img-00001-00062.nii ../scripts/img/img-00001-00063.nii ../scripts/img/img-00001-00064.nii ../scripts/img/img-00001-00065.nii ../scripts/img/img-00001-00066.nii ../scripts/img/img-00001-00067.nii ../scripts/img/img-00001-00068.nii ../scripts/img/img-00001-00069.nii ../scripts/img/img-00001-00070.nii ../scripts/img/img-00001-00071.nii ../scripts/img/img-00001-00072.nii ../scripts/img/img-00001-00073.nii ../scripts/img/img-00001-00074.nii ../scripts/img/img-00001-00075.nii ../scripts/img/img-00001-00076.nii ../scripts/img/img-00001-00077.nii ../scripts/img/img-00001-00078.nii ../scripts/img/img-00001-00079.nii ../scripts/img/img-00001-00080.nii ../scripts/img/img-00001-00081.nii ../scripts/img/img-00001-00082.nii ../scripts/img/img-00001-00083.nii ../scripts/img/img-00001-00084.nii ../scripts/img/img-00001-00085.nii ../scripts/img/img-00001-00086.nii ../scripts/img/img-00001-00087.nii ../scripts/img/img-00001-00088.nii ../scripts/img/img-00001-00089.nii ../scripts/img/img-00001-00090.nii ../scripts/img/img-00001-00091.nii ../scripts/img/img-00001-00092.nii ../scripts/img/img-00001-00093.nii ../scripts/img/img-00001-00094.nii ../scripts/img/img-00001-00095.nii ../scripts/img/img-00001-00096.nii ../scripts/img/img-00001-00097.nii ../scripts/img/img-00001-00098.nii ../scripts/img/img-00001-00099.nii ../scripts/img/img-00001-00100.nii ../scripts/img/img-00001-00101.nii ../scripts/img/img-00001-00102.nii ../scripts/img/img-00001-00103.nii ../scripts/img/img-00001-00104.nii ../scripts/img/img-00001-00105.nii ../scripts/img/img-00001-00106.nii ../scripts/img/img-00001-00107.nii ../scripts/img/img-00001-00108.nii ../scripts/img/img-00001-00109.nii ../scripts/img/img-00001-00110.nii ../scripts/img/img-00001-00111.nii ../scripts/img/img-00001-00112.nii ../scripts/img/img-00001-00113.nii ../scripts/img/img-00001-00114.nii ../scripts/img/img-00001-00115.nii ../scripts/img/img-00001-00116.nii ../scripts/img/img-00001-00117.nii ../scripts/img/img-00001-00118.nii ../scripts/img/img-00001-00119.nii ../scripts/img/img-00001-00120.nii ../scripts/img/img-00001-00121.nii ../scripts/img/img-00001-00122.nii ../scripts/img/img-00001-00123.nii ../scripts/img/img-00001-00124.nii ../scripts/img/img-00001-00125.nii ../scripts/img/img-00001-00126.nii ../scripts/img/img-00001-00127.nii ../scripts/img/img-00001-00128.nii ../scripts/img/img-00001-00129.nii ../scripts/img/img-00001-00130.nii ../scripts/img/img-00001-00131.nii ../scripts/img/img-00001-00132.nii ../scripts/img/img-00001-00133.nii ../scripts/img/img-00001-00134.nii ../scripts/img/img-00001-00135.nii ../scripts/img/img-00001-00136.nii ../scripts/img/img-00001-00137.nii ../scripts/img/img-00001-00138.nii ../scripts/img/img-00001-00139.nii ../scripts/img/img-00001-00140.nii ../scripts/img/img-00001-00141.nii ../scripts/img/img-00001-00142.nii ../scripts/img/img-00001-00143.nii ../scripts/img/img-00001-00144.nii ../scripts/img/img-00001-00145.nii ../scripts/img/img-00001-00146.nii ../scripts/img/img-00001-00147.nii ../scripts/img/img-00001-00148.nii ../scripts/img/img-00001-00149.nii ../scripts/img/img-00001-00150.nii ../scripts/img/img-00001-00151.nii ../scripts/img/img-00001-00152.nii ../scripts/img/img-00001-00153.nii ../scripts/img/img-00001-00154.nii ../scripts/img/img-00001-00155.nii ../scripts/img/img-00001-00156.nii ../scripts/img/img-00001-00157.nii ../scripts/img/img-00001-00158.nii ../scripts/img/img-00001-00159.nii ../scripts/img/img-00001-00160.nii ../scripts/img/img-00001-00161.nii ../scripts/img/img-00001-00162.nii ../scripts/img/img-00001-00163.nii ../scripts/img/img-00001-00164.nii ../scripts/img/img-00001-00165.nii ../scripts/img/img-00001-00166.nii ../scripts/img/img-00001-00167.nii ../scripts/img/img-00001-00168.nii ../scripts/img/img-00001-00169.nii ../scripts/img/img-00001-00170.nii ../scripts/img/img-00001-00171.nii ../scripts/img/img-00001-00172.nii ../scripts/img/img-00001-00173.nii ../scripts/img/img-00001-00174.nii ../scripts/img/img-00001-00175.nii ../scripts/img/img-00001-00176.nii ../scripts/img/img-00001-00177.nii ../scripts/img/img-00001-00178.nii ../scripts/img/img-00001-00179.nii ../scripts/img/img-00001-00180.nii ../scripts/img/img-00001-00181.nii ../scripts/img/img-00001-00182.nii ../scripts/img/img-00001-00183.nii ../scripts/img/img-00001-00184.nii ../scripts/img/img-00001-00185.nii ../scripts/img/img-00001-00186.nii ../scripts/img/img-00001-00187.nii ../scripts/img/img-00001-00188.nii ../scripts/img/img-00001-00189.nii ../scripts/img/img-00001-00190.nii ../scripts/img/img-00001-00191.nii ../scripts/img/img-00001-00192.nii ../scripts/img/img-00001-00193.nii ../scripts/img/img-00001-00194.nii ../scripts/img/img-00001-00195.nii ../scripts/img/img-00001-00196.nii ../scripts/img/img-00001-00197.nii ../scripts/img/img-00001-00198.nii ../scripts/img/img-00001-00199.nii ../scripts/img/img-00001-00200.nii ../scripts/img/img-00001-00201.nii ../scripts/img/img-00001-00202.nii ../scripts/img/img-00001-00203.nii ../scripts/img/img-00001-00204.nii ../scripts/img/img-00001-00205.nii ../scripts/img/img-00001-00206.nii ../scripts/img/img-00001-00207.nii ../scripts/img/img-00001-00208.nii ../scripts/img/img-00001-00209.nii ../scripts/img/img-00001-00210.nii 1.2 
    
    #../scripts/img/img-00001-00211.nii ../scripts/img/img-00001-00212.nii ../scripts/img/img-00001-00213.nii ../scripts/img/img-00001-00214.nii ../scripts/img/img-00001-00215.nii ../scripts/img/img-00001-00216.nii ../scripts/img/img-00001-00217.nii ../scripts/img/img-00001-00218.nii ../scripts/img/img-00001-00219.nii ../scripts/img/img-00001-00220.nii ../scripts/img/img-00001-00221.nii ../scripts/img/img-00001-00222.nii ../scripts/img/img-00001-00223.nii ../scripts/img/img-00001-00224.nii ../scripts/img/img-00001-00225.nii ../scripts/img/img-00001-00226.nii ../scripts/img/img-00001-00227.nii ../scripts/img/img-00001-00228.nii ../scripts/img/img-00001-00229.nii ../scripts/img/img-00001-00230.nii ../scripts/img/img-00001-00231.nii ../scripts/img/img-00001-00232.nii ../scripts/img/img-00001-00233.nii ../scripts/img/img-00001-00234.nii ../scripts/img/img-00001-00235.nii ../scripts/img/img-00001-00236.nii ../scripts/img/img-00001-00237.nii ../scripts/img/img-00001-00238.nii ../scripts/img/img-00001-00239.nii ../scripts/img/img-00001-00240.nii ../scripts/img/img-00001-00241.nii ../scripts/img/img-00001-00242.nii ../scripts/img/img-00001-00243.nii ../scripts/img/img-00001-00244.nii ../scripts/img/img-00001-00245.nii ../scripts/img/img-00001-00246.nii ../scripts/img/img-00001-00247.nii ../scripts/img/img-00001-00248.nii ../scripts/img/img-00001-00249.nii 1.2

    echo "+ computing resting state networks this will take about 25 minutes"
    echo "+ started at: $(date)"
    
    cp $fsl_scripts/rest_template.fsf $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    DATA_path=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii.gz
    OUTPUT_dir=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'
    sed -i "s#DATA#$DATA_path#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    sed -i "s#OUTPUT#$OUTPUT_dir#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    feat $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
fi

if [ ${step} = process_roi_masks ]
then
clear
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "+ Generating DMN, CEN and SMC masks. "
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    touch $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/Yeo_rsn_correl.txt
correlfile=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/Yeo_rsn_correl.txt

infile=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/melodic_IC.nii.gz 

infile_2mm=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/melodic_IC_2mm.nii.gz

examplefunc=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/example_func.nii.gz

standard=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/standard.nii.gz

example_func2standard_mat=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/example_func2standard.mat

standard2example_func_mat=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/standard2example_func.mat

yeo7networks=../scripts/FSL_7networks.nii

yeo7networks2example_func=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/reg/yeo7networks2example_func.nii.gz


flirt -in ${yeo7networks} -ref ${examplefunc} -out ${yeo7networks2example_func} -init ${standard2example_func_mat} -applyxfm


split_outfile=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/melodic_IC_


fslcc --noabs -p 3 -t 0.05 ${infile} ${yeo7networks2example_func} >>${correlfile}
fslsplit ${infile} ${split_outfile}

python rsn_get.py ${subj} ${ses} ${run}


dmn_uthresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/dmn_uthresh.nii.gz
cen_uthresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/cen_uthresh.nii.gz
smc_uthresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/smc_uthresh.nii.gz

dmn_thresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/dmn_thresh.txt
cen_thresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/cen_thresh.txt
smc_thresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/smc_thresh.txt

dmn_mni_thresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/dmn_mni_thresh.nii.gz
cen_mni_thresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/cen_mni_thresh.nii.gz
smc_mni_thresh=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.ica/filtered_func_data.ica/smc_mni_thresh.nii.gz



#Here you can change the size of the DMN/CEN mask
#thresh=500
threshvalue=99.7
#while [$thresh>=100]
#do
#threshvalue=$(($threshvalue +0.01)) | bc
fslstats ${dmn_uthresh} -P $threshvalue >${dmn_thresh}
thresh="$(awk '{print $1}' ${dmn_thresh})"
fslmaths ${dmn_uthresh} -thr ${thresh} -bin ${dmn_mni_thresh} -odt short
flirt -in  ${dmn_mni_thresh} -ref ${standard} -out ${dmn_mni_thresh} -init ${example_func2standard_mat} -applyxfm
fslmaths ${dmn_mni_thresh} -mul ../scripts/FSL_7networks_DMN.nii.gz ${dmn_mni_thresh}

fslstats ${cen_uthresh} -P $threshvalue >${cen_thresh}
thresh="$(awk '{print $1}' ${cen_thresh})"
fslmaths ${cen_uthresh} -thr ${thresh} -bin ${cen_mni_thresh} -odt short
flirt -in  ${cen_mni_thresh} -ref ${standard} -out ${cen_mni_thresh} -init ${example_func2standard_mat} -applyxfm
fslmaths ${cen_mni_thresh} -mul ../scripts/FSL_7networks_CEN.nii.gz ${cen_mni_thresh}

fslstats ${smc_uthresh} -P $threshvalue >${smc_thresh}
thresh="$(awk '{print $1}' ${smc_thresh})"
fslmaths ${smc_uthresh} -thr ${thresh} -bin ${smc_mni_thresh} -odt short
flirt -in  ${smc_mni_thresh} -ref ${standard} -out ${smc_mni_thresh} -init ${example_func2standard_mat} -applyxfm
fslmaths ${smc_mni_thresh} -mul ../scripts/FSL_7networks_SMC.nii.gz ${smc_mni_thresh}

cp ${dmn_mni_thresh} ${subj_dir}/mask/mni/dmn_mni.nii.gz
cp ${cen_mni_thresh} ${subj_dir}/mask/mni/cen_mni.nii.gz
cp ${smc_mni_thresh} ${subj_dir}/mask/mni/smc_mni.nii.gz

fsleyes  mean_brain.nii.gz ${subj_dir}/mask/mni/dmn_mni.nii.gz -cm blue ${subj_dir}/mask/mni/cen_mni.nii.gz -cm red ${subj_dir}/mask/mni/smc_mni.nii.gz -cm green

fi
