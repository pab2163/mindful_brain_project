import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import os.path
import subprocess
import os
from glob import glob
import sys
import pandas as pd


template_networks='template_networks.nii.gz'
dmn_template='../../murfi-rt-PyProject/scripts/DMNax_brainmaskero2.nii'
cen_template='../../murfi-rt-PyProject/scripts/CENa_brainmaskero2.nii'
os.system(f'fslmerge -t {template_networks} {dmn_template} {cen_template}')

os.system('mkdir masks')

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

    # get number of non-zero voxels in masks, calculate percentile cutofff needed for the desired absolute number of voxels
    voxels_in_dmn=7750
    voxels_in_cen=3731

    percentile_dmn=100*(1-(num_voxels_desired/voxels_in_dmn))
    percentile_cen=100*(1-(num_voxels_desired/voxels_in_cen))

    # threshold masks at the given percentile
    os.system(f'fslmaths {dmn_component} -thrp {percentile_dmn} -bin {dmn_thresh} -odt short')
    os.system(f'fslmaths {cen_component} -thrp {percentile_cen} -bin {cen_thresh} -odt short')

    # copy masks to participant's mask directory
    os.system(f'mv {dmn_thresh} masks/{subid}_dmn_mask.nii.gz')
    os.system(f'mv {cen_thresh} masks/{subid}_cen_mask.nii.gz')


subs = ['sub-rtBANDA049']#, 'sub-rtBANDA056', 'sub-rtBANDA060', 'sub-rtBANDA066', 'sub-rtBANDA073',
        #'sub-rtBANDA088', 'sub-rtBANDA106', 'sub-rtBANDA116', 'sub-rtBANDA145']

for i in subs:
    make_masks_one_participant(subid=i)