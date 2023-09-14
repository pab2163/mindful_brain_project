import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from nilearn import image as nimg
from nilearn import plotting 
from nilearn import masking
import os.path
import subprocess
import os
from glob import glob
import sys
import pandas as pd

# Set up files used for all participants
template_networks='template_networks.nii.gz'
dmn_template='../../murfi-rt-PyProject/scripts/DMNax_brainmaskero2.nii'
cen_template='../../murfi-rt-PyProject/scripts/CENa_brainmaskero2.nii'
os.system(f'fslmerge -t {template_networks} {dmn_template} {cen_template}')
os.system('mkdir masks')
os.system('mkdir masks/mpfc_pcc')

def make_masks_one_participant(subid):
    # set up filepaths
    ica_directory=f'../../../rtBANDA/resting/ica_outputs/{subid}.gica/groupmelodic.ica/'
    ica_output=f'{ica_directory}/melodic_IC.nii.gz'

    brain_mask='../../murfi-rt-PyProject/scripts/MNI152_T1_2mm_brain_mask.nii.gz'
    split_outfile=f'{ica_directory}/melodic_IC_'

    # create file of correlations between ALL ICs and DMN/FPN
    correlfile= f'{ica_directory}/template_rsn_correlations_with_ICs.txt'
    os.system(f'touch {correlfile}')
    os.system(f'rm -f {correlfile}')

    # correlate ICs with templates (spatially)
    os.system(f'fslcc --noabs -p 8 -t -1 -m {brain_mask} {ica_output} {template_networks}>>{correlfile}')

    # Split ICs to separate files
    os.system(f'fslsplit {ica_output} {split_outfile}')

    # unthresholded masks
    dmn_component=f'{ica_directory}/dmn_uthresh.nii.gz'
    cen_component=f'{ica_directory}/cen_uthresh.nii.gz' 
    dmn_thresh=f'{ica_directory}/dmn_thresh.nii.gz'
    cen_thresh=f'{ica_directory}/cen_thresh.nii.gz' 

    '''
    Read correlation file
    3 columns: IC#, Yeo Network # (DMN=1, CEN=2), Correlation
    '''
    
    fslcc_info = pd.read_csv(correlfile, sep=' ', skipinitialspace=True, header=None)
    fslcc_info.columns= ['ic_number', 'yeo_network_number', 'correlation']

    # Absolute value of correlations (ICs could be negatively correlated with corresponding networks)
    fslcc_info['correlation_abs'] = np.abs(fslcc_info.correlation)
    fslcc_info.sort_values(by=['correlation_abs', 'yeo_network_number'], ascending=False, inplace=True)

    # Correlations specifically with DMN and CEN
    dmn_info = fslcc_info[fslcc_info.yeo_network_number == 1]
    cen_info = fslcc_info[fslcc_info.yeo_network_number == 2]

    # Select ICs with strongest absolute value correlations
    dmn_strongest_ic = dmn_info[dmn_info.correlation_abs == dmn_info.correlation_abs.max()].head(1)
    cen_strongest_ic = cen_info[cen_info.correlation_abs == cen_info.correlation_abs.max()].head(1)

    dmn_ic_selection = int(dmn_strongest_ic.ic_number)-1
    cen_ic_selection  = int(cen_strongest_ic.ic_number)-1

    print('DMN:', dmn_strongest_ic)
    print('CEN:', cen_strongest_ic)

    print(f'DMN: melodic_IC_{dmn_ic_selection}')
    print(f'CEN: melodic_IC_{cen_ic_selection}')

    # Pull the correct IC nifti files
    dmnfuncfile=split_outfile+'%0.4d.nii.gz' % dmn_ic_selection
    cenfuncfile=split_outfile+'%0.4d.nii.gz' % cen_ic_selection

    # Copy IC nifti files to new location as unthreshold DMN/CEN components
    os.system('cp %s %s' %(dmnfuncfile,dmn_component))
    os.system('cp %s %s' %(cenfuncfile,cen_component))

    # If either IC was loading negatively on the respective network, flip the sign of all voxels by multiplying by -1
    if float(dmn_strongest_ic.correlation) < 0:
        print('Flipping IC Loadings for DMN')
        os.system(f'fslmaths {dmn_component} -mul -1 {dmn_component}')

    if float(cen_strongest_ic.correlation) < 0:
        print('Flipping IC Loadings for CEN')
        os.system(f'fslmaths {cen_component} -mul -1 {cen_component}')

    # Hard code the number of voxels desired for each mask
    num_voxels_desired=2000

    # zero out voxels not included in the template masks (i.e. so we only select voxels within template DMN/CEN)
    os.system(f'fslmaths {dmn_component} -mul {dmn_template} {dmn_component}')
    os.system(f'fslmaths {cen_component} -mul {cen_template} {cen_component}')

    # calculate the thresholds to extract exactly 2000 voxels for DMN and CEN masks
    dmn_nilearn = nimg.load_img(dmn_component).get_fdata()
    dmn_nilearn = dmn_nilearn[dmn_nilearn>0]
    cen_nilearn = nimg.load_img(cen_component).get_fdata()
    cen_nilearn = cen_nilearn[cen_nilearn>0]
    dmn_threshold_value = dmn_nilearn.flatten()
    dmn_threshold_value.sort()
    dmn_threshold_value=dmn_threshold_value[-2000]
    cen_threshold_value = cen_nilearn.flatten()
    cen_threshold_value.sort()
    cen_threshold_value=cen_threshold_value[-2000]

    # use fslmaths to threshold
    os.system(f'fslmaths {dmn_component} -thr {dmn_threshold_value} -bin {dmn_thresh} -odt short')
    os.system(f'fslmaths {cen_component} -thr {cen_threshold_value} -bin {cen_thresh} -odt short')


    # copy masks to participant's mask directory
    os.system(f'mv {dmn_thresh} masks/{subid}_dmn_mask.nii.gz')
    os.system(f'mv {cen_thresh} masks/{subid}_cen_mask.nii.gz')

    print('Numbers of voxels in masks')
    os.system(f'fslstats masks/{subid}_dmn_mask.nii.gz -V')
    os.system(f'fslstats masks/{subid}_cen_mask.nii.gz -V')

    dmn_output = nimg.load_img(f'masks/{subid}_dmn_mask.nii.gz')
    plotting.plot_roi(roi_img=dmn_output, cut_coords=(-2, 49, 5),
                      output_file = f'mask_plots/{subid}_dmn.png')
    plt.close()

    # check how many voxels in mpfc and pcc
    mpfc_mask=nimg.load_img('../ROI/DMNax_brainmaskero2_mpfc_mask.nii.gz')
    pcc_mask=nimg.load_img('../ROI/DMNax_brainmaskero2_pcc_mask.nii.gz')
    mpfc_masked=masking.apply_mask(dmn_output, mpfc_mask)
    pcc_masked=masking.apply_mask(dmn_output, pcc_mask)
    voxels_in_mpfc = sum(mpfc_masked>0)
    voxels_in_pcc = sum(pcc_masked>0)

    #### ----------------------------------------------------
    # Make 1000-voxel PCC and mPFC masks for each partcipant
    #### ----------------------------------------------------
    ic_mpfc_path=f'{ica_directory}/dmn_ic_mpfc_masked.nii.gz'
    ic_pcc_path=f'{ica_directory}/dmn_ic_pcc_masked.nii.gz'
    os.system(f'fslmaths {dmn_component} -mul ../ROI/DMNax_brainmaskero2_mpfc_mask.nii.gz {ic_mpfc_path}')
    os.system(f'fslmaths {dmn_component} -mul ../ROI/DMNax_brainmaskero2_pcc_mask.nii.gz {ic_pcc_path}')

    # get threshold values for personalized 1000-voxel mPFC and PCCs
    mpfc_ic_img=nimg.load_img(ic_mpfc_path).get_fdata()
    pcc_ic_img=nimg.load_img(ic_pcc_path).get_fdata()
    mpfc_ic_threshold_value = mpfc_ic_img.flatten()
    mpfc_ic_threshold_value.sort()
    mpfc_ic_threshold_value=mpfc_ic_threshold_value[-1000]
    pcc_ic_threshold_value = pcc_ic_img.flatten()
    pcc_ic_threshold_value.sort()
    pcc_ic_threshold_value=pcc_ic_threshold_value[-1000]

    mpfc_thresh=f'masks/mpfc_pcc/{subid}_mpfc1000voxels.nii.gz'
    pcc_thresh=f'masks/mpfc_pcc/{subid}_pcc1000voxels.nii.gz'
    mpfc_pcc_thresh=f'masks/mpfc_pcc/{subid}_combined_mpfc_pcc1000voxels.nii.gz'

    # use fslmaths to threshold & binarize mpfc/pcc masks
    os.system(f'fslmaths {ic_mpfc_path} -thr {mpfc_ic_threshold_value} -bin {mpfc_thresh} -odt short')
    os.system(f'fslmaths {ic_pcc_path} -thr {pcc_ic_threshold_value} -bin {pcc_thresh} -odt short')

    # combine them
    os.system(f'fslmaths {mpfc_thresh} -add {pcc_thresh} {mpfc_pcc_thresh} -odt short')
    os.system(f'fslstats {mpfc_thresh} -V')
    os.system(f'fslstats {pcc_thresh} -V')


    combined_mpfc_pcc = nimg.load_img(f'{mpfc_pcc_thresh}')
    plotting.plot_roi(roi_img=combined_mpfc_pcc, cut_coords=(-2, 49, 5),
                      output_file = f'mask_plots/{subid}_combined_mpfc_pcc.png')
    plt.close()

    outdata = {'subid':subid,
               'dmn_ic':dmn_ic_selection,
               'cen_ic': cen_ic_selection,
               'mpfc_voxels':voxels_in_mpfc,
               'pcc_voxels': voxels_in_pcc}
    
    return(outdata)

subs = ['sub-rtBANDA049', 'sub-rtBANDA056', 'sub-rtBANDA060', 'sub-rtBANDA066', 'sub-rtBANDA073',
        'sub-rtBANDA088', 'sub-rtBANDA106', 'sub-rtBANDA116', 'sub-rtBANDA145']

# run and save out counts of voxels in mpfc/pcc
voxelcount_list = []
for i in subs:
    voxelcount_list.append(make_masks_one_participant(subid=i))

voxelcounts=pd.DataFrame(voxelcount_list)
voxelcounts.to_csv('rtbanda_mpfc_pcc_voxel_counts.csv')
