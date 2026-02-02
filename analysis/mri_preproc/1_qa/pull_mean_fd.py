import glob
import os
import pandas as pd

all_confound_files = glob.glob('/neurodata/mindful_brain_project/data/fmriprep/fmriprep-23.2.1/sub-remind*/ses*/func/*confounds_timeseries.tsv')


'''
get mean fd from one confound file
'''
def mean_fd(filepath):
    df = pd.read_csv(filepath, sep = '\t')
    mean_fd = df['framewise_displacement'].mean()

    output = {'filename': filepath,
              'mean_fd': mean_fd}

    return(output)

# loop through all confound files
output_list = []
for file in all_confound_files:
    output_list.append(mean_fd(file))


# merge to dataframe and save out to csv
all_fd = pd.DataFrame(output_list)
all_fd.to_csv('mean_fd_summary.csv', index=False)
