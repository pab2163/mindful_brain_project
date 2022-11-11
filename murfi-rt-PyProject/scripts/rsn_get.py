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
ses = sys.argv[2]
run = sys.argv[3]



# # get correls to Yeo 7networks
correlfile="../subjects/%s/rest/%s_%s_task-rest_%s_bold.ica/filtered_func_data.ica/Yeo_rsn_correl.txt" %(subjID,subjID,ses,run)
split_outfile='../subjects/%s/rest/%s_%s_task-rest_%s_bold.ica/filtered_func_data.ica/melodic_IC_' %(subjID,subjID,ses,run)
dmn_component='../subjects/%s/rest/%s_%s_task-rest_%s_bold.ica/filtered_func_data.ica/dmn_uthresh.nii.gz' %(subjID,subjID,ses,run)
cen_component='../subjects/%s/rest/%s_%s_task-rest_%s_bold.ica/filtered_func_data.ica/cen_uthresh.nii.gz' %(subjID,subjID,ses,run)
#smc_component='../subjects/%s/rest/%s_%s_task-rest_%s_bold.ica/filtered_func_data.ica/smc_uthresh.nii.gz' %(subjID,subjID,ses,run)
#

 # get DMN, CEN, SMC
fslcc_info = pd.read_csv(correlfile, sep=' ', skipinitialspace=True, header=None)
list(fslcc_info)
fslcc_info.sort_values(by=[1, 2], ascending=False, inplace=True)
dmn_info = fslcc_info.loc[fslcc_info[1] == 7, :].values
cen_info = fslcc_info.loc[fslcc_info[1] == 6, :].values
#smc_info = fslcc_info.loc[fslcc_info[1] == 2, :].values

roi1 = int(dmn_info[0, 0]-1)
roi2  = int(cen_info[0, 0]-1)
#roi3  = int(smc_info[0, 0]-1)

dmnfuncfile=split_outfile+'%0.4d.nii.gz' % roi1
cenfuncfile=split_outfile+'%0.4d.nii.gz' % roi2
#smcfuncfile=split_outfile+'%0.4d.nii.gz' % roi3

os.system('cp %s %s' %(dmnfuncfile,dmn_component))
os.system('cp %s %s' %(cenfuncfile,cen_component))
#os.system('cp %s %s' %(smcfuncfile,smc_component))




