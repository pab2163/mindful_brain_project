'''
Takes arguements for any folders that should be synced from the discovery cluster

Note: requires login access to discovery and will promppt with password!
'''

import sys
import os

data_folder=sys.argv[1]

cmd=f'rsync -avz p.bloom@xfer.discovery.neu.edu:/work/swglab/data/remind/sourcedata/dicoms/\
{data_folder} /Volumes/columbia/mbNF_MDD/DATA/MRI/from_neu/sourcedata'

print(cmd)
os.system(cmd)
