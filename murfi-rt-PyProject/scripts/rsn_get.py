#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from nipype.interfaces import fsl
from nipype.interfaces.fsl import MotionOutliers
import os.path
import subprocess
import os
from glob import glob
import sys
import pandas as pd
from nipype.interfaces.fsl import ImageStats

subjID = sys.argv[1]
ica_version=sys.argv[2]

if ica_version == 'multi_run':
    ica_directory=f'../subjects/{subjID}/rest/rs_network.gica/groupmelodic.ica/'
    dmn_component=f'{ica_directory}/dmn_uthresh.nii.gz'
    cen_component=f'{ica_directory}/cen_uthresh.nii.gz' 
elif ica_version == 'single_run':
    ica_directory=f'../subjects/{subjID}/rest/rs_network.ica/'
    dmn_component=f'{ica_directory}/dmn_uthresh.nii.gz'
    cen_component=f'{ica_directory}/cen_uthresh.nii.gz' 

# Define file paths for file with correlations and IC output files
correlfile=f'{ica_directory}/template_rsn_correlations_with_ICs.txt' 
split_outfile=f'{ica_directory}/melodic_IC_'

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