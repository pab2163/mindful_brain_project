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
    cp $subj_dir/img/img-00002-00002.nii  $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii
    yes n | gzip $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii

    #fslmerge -tr $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii.gz $subj_dir/img/img-00002-00002.nii $subj_dir/img/img-00002-00003.nii $subj_dir/img/img-00002-00004.nii $subj_dir/img/img-00002-00005.nii $subj_dir/img/img-00002-00006.nii $subj_dir/img/img-00002-00007.nii $subj_dir/img/img-00002-00008.nii $subj_dir/img/img-00002-00009.nii $subj_dir/img/img-00002-00010.nii $subj_dir/img/img-00002-00011.nii $subj_dir/img/img-00002-00012.nii $subj_dir/img/img-00002-00013.nii $subj_dir/img/img-00002-00014.nii $subj_dir/img/img-00002-00015.nii $subj_dir/img/img-00002-00016.nii $subj_dir/img/img-00002-00017.nii $subj_dir/img/img-00002-00018.nii $subj_dir/img/img-00002-00019.nii $subj_dir/img/img-00002-00020.nii $subj_dir/img/img-00002-00021.nii $subj_dir/img/img-00002-00022.nii $subj_dir/img/img-00002-00023.nii $subj_dir/img/img-00002-00024.nii $subj_dir/img/img-00002-00025.nii $subj_dir/img/img-00002-00026.nii $subj_dir/img/img-00002-00027.nii $subj_dir/img/img-00002-00028.nii $subj_dir/img/img-00002-00029.nii $subj_dir/img/img-00002-00030.nii $subj_dir/img/img-00002-00031.nii $subj_dir/img/img-00002-00032.nii $subj_dir/img/img-00002-00033.nii $subj_dir/img/img-00002-00034.nii $subj_dir/img/img-00002-00035.nii $subj_dir/img/img-00002-00036.nii $subj_dir/img/img-00002-00037.nii $subj_dir/img/img-00002-00038.nii $subj_dir/img/img-00002-00039.nii $subj_dir/img/img-00002-00040.nii $subj_dir/img/img-00002-00041.nii $subj_dir/img/img-00002-00042.nii $subj_dir/img/img-00002-00043.nii $subj_dir/img/img-00002-00044.nii $subj_dir/img/img-00002-00045.nii $subj_dir/img/img-00002-00046.nii $subj_dir/img/img-00002-00047.nii $subj_dir/img/img-00002-00048.nii $subj_dir/img/img-00002-00049.nii $subj_dir/img/img-00002-00050.nii $subj_dir/img/img-00002-00051.nii $subj_dir/img/img-00002-00052.nii $subj_dir/img/img-00002-00053.nii $subj_dir/img/img-00002-00054.nii $subj_dir/img/img-00002-00055.nii $subj_dir/img/img-00002-00056.nii $subj_dir/img/img-00002-00057.nii $subj_dir/img/img-00002-00058.nii $subj_dir/img/img-00002-00059.nii $subj_dir/img/img-00002-00060.nii $subj_dir/img/img-00002-00061.nii $subj_dir/img/img-00002-00062.nii $subj_dir/img/img-00002-00063.nii $subj_dir/img/img-00002-00064.nii $subj_dir/img/img-00002-00065.nii $subj_dir/img/img-00002-00066.nii $subj_dir/img/img-00002-00067.nii $subj_dir/img/img-00002-00068.nii $subj_dir/img/img-00002-00069.nii $subj_dir/img/img-00002-00070.nii $subj_dir/img/img-00002-00071.nii $subj_dir/img/img-00002-00072.nii $subj_dir/img/img-00002-00073.nii $subj_dir/img/img-00002-00074.nii $subj_dir/img/img-00002-00075.nii $subj_dir/img/img-00002-00076.nii $subj_dir/img/img-00002-00077.nii $subj_dir/img/img-00002-00078.nii $subj_dir/img/img-00002-00079.nii $subj_dir/img/img-00002-00080.nii $subj_dir/img/img-00002-00081.nii $subj_dir/img/img-00002-00082.nii $subj_dir/img/img-00002-00083.nii $subj_dir/img/img-00002-00084.nii $subj_dir/img/img-00002-00085.nii $subj_dir/img/img-00002-00086.nii $subj_dir/img/img-00002-00087.nii $subj_dir/img/img-00002-00088.nii $subj_dir/img/img-00002-00089.nii $subj_dir/img/img-00002-00090.nii $subj_dir/img/img-00002-00091.nii $subj_dir/img/img-00002-00092.nii $subj_dir/img/img-00002-00093.nii $subj_dir/img/img-00002-00094.nii $subj_dir/img/img-00002-00095.nii $subj_dir/img/img-00002-00096.nii $subj_dir/img/img-00002-00097.nii $subj_dir/img/img-00002-00098.nii $subj_dir/img/img-00002-00099.nii $subj_dir/img/img-00002-00100.nii $subj_dir/img/img-00002-00101.nii $subj_dir/img/img-00002-00102.nii $subj_dir/img/img-00002-00103.nii $subj_dir/img/img-00002-00104.nii $subj_dir/img/img-00002-00105.nii $subj_dir/img/img-00002-00106.nii $subj_dir/img/img-00002-00107.nii $subj_dir/img/img-00002-00108.nii $subj_dir/img/img-00002-00109.nii $subj_dir/img/img-00002-00110.nii $subj_dir/img/img-00002-00111.nii $subj_dir/img/img-00002-00112.nii $subj_dir/img/img-00002-00113.nii $subj_dir/img/img-00002-00114.nii $subj_dir/img/img-00002-00115.nii $subj_dir/img/img-00002-00116.nii $subj_dir/img/img-00002-00117.nii $subj_dir/img/img-00002-00118.nii $subj_dir/img/img-00002-00119.nii $subj_dir/img/img-00002-00120.nii $subj_dir/img/img-00002-00121.nii $subj_dir/img/img-00002-00122.nii $subj_dir/img/img-00002-00123.nii $subj_dir/img/img-00002-00124.nii $subj_dir/img/img-00002-00125.nii $subj_dir/img/img-00002-00126.nii $subj_dir/img/img-00002-00127.nii $subj_dir/img/img-00002-00128.nii $subj_dir/img/img-00002-00129.nii $subj_dir/img/img-00002-00130.nii $subj_dir/img/img-00002-00131.nii $subj_dir/img/img-00002-00132.nii $subj_dir/img/img-00002-00133.nii $subj_dir/img/img-00002-00134.nii $subj_dir/img/img-00002-00135.nii $subj_dir/img/img-00002-00136.nii $subj_dir/img/img-00002-00137.nii $subj_dir/img/img-00002-00138.nii $subj_dir/img/img-00002-00139.nii $subj_dir/img/img-00002-00140.nii $subj_dir/img/img-00002-00141.nii $subj_dir/img/img-00002-00142.nii $subj_dir/img/img-00002-00143.nii $subj_dir/img/img-00002-00144.nii $subj_dir/img/img-00002-00145.nii $subj_dir/img/img-00002-00146.nii $subj_dir/img/img-00002-00147.nii $subj_dir/img/img-00002-00148.nii $subj_dir/img/img-00002-00149.nii $subj_dir/img/img-00002-00150.nii $subj_dir/img/img-00002-00151.nii $subj_dir/img/img-00002-00152.nii $subj_dir/img/img-00002-00153.nii $subj_dir/img/img-00002-00154.nii $subj_dir/img/img-00002-00155.nii $subj_dir/img/img-00002-00156.nii $subj_dir/img/img-00002-00157.nii $subj_dir/img/img-00002-00158.nii $subj_dir/img/img-00002-00159.nii $subj_dir/img/img-00002-00160.nii $subj_dir/img/img-00002-00161.nii $subj_dir/img/img-00002-00162.nii $subj_dir/img/img-00002-00163.nii $subj_dir/img/img-00002-00164.nii $subj_dir/img/img-00002-00165.nii $subj_dir/img/img-00002-00166.nii $subj_dir/img/img-00002-00167.nii $subj_dir/img/img-00002-00168.nii $subj_dir/img/img-00002-00169.nii $subj_dir/img/img-00002-00170.nii $subj_dir/img/img-00002-00171.nii $subj_dir/img/img-00002-00172.nii $subj_dir/img/img-00002-00173.nii $subj_dir/img/img-00002-00174.nii $subj_dir/img/img-00002-00175.nii $subj_dir/img/img-00002-00176.nii $subj_dir/img/img-00002-00177.nii $subj_dir/img/img-00002-00178.nii $subj_dir/img/img-00002-00179.nii $subj_dir/img/img-00002-00180.nii $subj_dir/img/img-00002-00181.nii $subj_dir/img/img-00002-00182.nii $subj_dir/img/img-00002-00183.nii $subj_dir/img/img-00002-00184.nii $subj_dir/img/img-00002-00185.nii $subj_dir/img/img-00002-00186.nii $subj_dir/img/img-00002-00187.nii $subj_dir/img/img-00002-00188.nii $subj_dir/img/img-00002-00189.nii $subj_dir/img/img-00002-00190.nii $subj_dir/img/img-00002-00191.nii $subj_dir/img/img-00002-00192.nii $subj_dir/img/img-00002-00193.nii $subj_dir/img/img-00002-00194.nii $subj_dir/img/img-00002-00195.nii $subj_dir/img/img-00002-00196.nii $subj_dir/img/img-00002-00197.nii $subj_dir/img/img-00002-00198.nii $subj_dir/img/img-00002-00199.nii $subj_dir/img/img-00002-00200.nii $subj_dir/img/img-00002-00201.nii $subj_dir/img/img-00002-00202.nii $subj_dir/img/img-00002-00203.nii $subj_dir/img/img-00002-00204.nii $subj_dir/img/img-00002-00205.nii $subj_dir/img/img-00002-00206.nii $subj_dir/img/img-00002-00207.nii $subj_dir/img/img-00002-00208.nii $subj_dir/img/img-00002-00209.nii $subj_dir/img/img-00002-00210.nii 1.2 
    
    fslmerge -tr $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii.gz $subj_dir/img/img-00002* 1.2
    chmod 777 $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii.gz 
    #restvolumes=$(fslnvols $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii.gz)

    #../scripts/img/img-00001-00211.nii ../scripts/img/img-00001-00212.nii ../scripts/img/img-00001-00213.nii ../scripts/img/img-00001-00214.nii ../scripts/img/img-00001-00215.nii ../scripts/img/img-00001-00216.nii ../scripts/img/img-00001-00217.nii ../scripts/img/img-00001-00218.nii ../scripts/img/img-00001-00219.nii ../scripts/img/img-00001-00220.nii ../scripts/img/img-00001-00221.nii ../scripts/img/img-00001-00222.nii ../scripts/img/img-00001-00223.nii ../scripts/img/img-00001-00224.nii ../scripts/img/img-00001-00225.nii ../scripts/img/img-00001-00226.nii ../scripts/img/img-00001-00227.nii ../scripts/img/img-00001-00228.nii ../scripts/img/img-00001-00229.nii ../scripts/img/img-00001-00230.nii ../scripts/img/img-00001-00231.nii ../scripts/img/img-00001-00232.nii ../scripts/img/img-00001-00233.nii ../scripts/img/img-00001-00234.nii ../scripts/img/img-00001-00235.nii ../scripts/img/img-00001-00236.nii ../scripts/img/img-00001-00237.nii ../scripts/img/img-00001-00238.nii ../scripts/img/img-00001-00239.nii ../scripts/img/img-00001-00240.nii ../scripts/img/img-00001-00241.nii ../scripts/img/img-00001-00242.nii ../scripts/img/img-00001-00243.nii ../scripts/img/img-00001-00244.nii ../scripts/img/img-00001-00245.nii ../scripts/img/img-00001-00246.nii ../scripts/img/img-00001-00247.nii ../scripts/img/img-00001-00248.nii ../scripts/img/img-00001-00249.nii 1.2

    echo "+ computing resting state networks this will take about 25 minutes"
    echo "+ started at: $(date)"
    
    cp $fsl_scripts/rest_template.fsf $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    DATA_path=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.nii.gz
    OUTPUT_dir=$subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'
    sed -i "s#DATA#$DATA_path#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
    sed -i "s#OUTPUT#$OUTPUT_dir#g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf

    # update fsf to match number of rest volumes
    sed -i "s/set fmri(npts) 248/set fmri(npts) ${restvolumes}/g" $subj_dir/rest/$subj'_'$ses'_task-rest_'$run'_bold'.fsf
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
