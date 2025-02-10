import logging
from datetime import datetime
import os
import re
import glob

# Configure logging
log_filename = f"bidsify_logs/bidsify_log_{datetime.now().strftime('%Y-%m-%d')}.txt"
logging.basicConfig(filename=log_filename, level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def log_and_print(message, level="info"):
    print(message)
    if level == "info":
        logging.info(message)
    elif level == "warning":
        logging.warning(message)
    elif level == "error":
        logging.error(message)



pattern = re.compile(r"remind\d{4}")

# paths
cu_path = '/neurodata/mindful_brain_project/data/dicom_raw/cu/*'
neu_path = '/neurodata/mindful_brain_project/data/dicom_raw/neu/*'


# get cu ids
cu_folders= glob.glob(cu_path)
unique_remind_ids = list({match.group() for folder in cu_folders if (match := pattern.search(folder))})

# get neu ids
neu_folders= glob.glob(neu_path)

# Extract unique remind IDs
unique_remind_ids_neu = list({match.group() for folder in neu_folders if (match := pattern.search(folder))})

# combine neu and cu ides
unique_remind_ids.extend(unique_remind_ids_neu)

# Print ids
log_and_print(sorted(unique_remind_ids))
log_and_print(f'Total of {len(unique_remind_ids)} participants found')

# paths to prepped dicoms/bids data
prepped_dicom_path='/neurodata/mindful_brain_project/data/dicom_prepped_for_heudiconv'
bids_path = '/neurodata/mindful_brain_project/data/bids_data'

def run_pipeline_one_participant(id):
	log_and_print(f'\n{id}')
	'''
	run dicom prep only if output prepped directory doesn't exist
	this step 
		a) reorganizes the dicoms into the prepped_dicom_path folder
		b) removes unwanted dicoms specified in text files 
		c) removes dicom types always bids ignored

	after this step, neu/cu data should be basically in the same format, ready for heudiconv

	'''
	prep_command=f'python 1_prep_for_heudiconv.py {id}'
	if os.path.isdir(f'{prepped_dicom_path}/{id}'):
		log_and_print(f'Dicom prep already exists for {id}')
	else:
		log_and_print(f'Prepping dicoms for {id}')
		os.system(prep_command)


	'''
	Run heudiconv only if output bids folder doesn't exist
	Uses heuristic.py to bidsify all dicoms!
	Have to do this separately for loc / nf sessions
	
	Make sure to delete prior hidden .heudiconv directroy in the bids output first
	Otherwise, bidsification might not be up to date if edits are made to heuristic.py

	'''
	# heudiconv_command_cleanup=f'rm -rf {bids_path}/.heudiconv/{id}'
	# heudiconv_command_loc=f'bash run_heudiconv.sh {id} loc'
	# heudiconv_command_nf=f'bash run_heudiconv.sh {id} loc'

	# if os.path.isdir(f'{bids_path}/sub-{id}'):
	# 	log_and_print(f'BIDSified data already exists for {id}')
	# else:
	# 	log_and_print(f'Running heudiconv to bidsify data for {id}')
	# 	os.system(heudiconv_command_cleanup)
	# 	os.system(heudiconv_command_loc)
	# 	os.system(heudiconv_command_nf)


# loop through ids to prep dicoms / bidsfy
for id in unique_remind_ids:
	try:
		run_pipeline_one_participant(id)
	except Exception as e:
		log_and_print(f'ERROR, {e}')



