import glob
from pathlib import Path
import os
import sys

def organize_dicoms(main_path, dicom_out_path, subject):
    '''
    Organizes dicoms pre-heudiconv for one subject
    '''
    
    # find out if file specifying exclusions exists
    exclude_runlist_path=f'bids_ignore_files/{subject}.txt'
    
    if os.path.isfile(exclude_runlist_path):
        runs_to_exclude=True
        with open(exclude_runlist_path, 'r') as file:
            bids_ignore_runs = file.readlines()

        # Remove trailing newline characters from each line
        bids_ignore_runs = [line.rstrip('\n') for line in bids_ignore_runs]
        print(bids_ignore_runs)

    else:
        print(f'No file exists marking runs to be ignored for {subject} - is this correct?')
        runs_to_exclude=False

    sub_out_path = f'{dicom_out_path}/{subject}/'
    os.system(f'mkdir {sub_out_path}')
    os.system(f'mkdir {sub_out_path}/loc')
    os.system(f'mkdir {sub_out_path}/nf')

    site = ''
    # For CU data (subject id remind2###) - need to unzip dicoms
    if 'remind2' in subject:
        site = 'cu'
        old_session_labels = glob.glob(f'{main_path}/cu/{subject}/*')
        for label in old_session_labels:
            print(label)
            if label.endswith('Auerbach^REMIND') or label.endswith('loc'):
                session = 'loc'
                if label.endswith('Auerbach^REMIND'):
                    os.system(f"mv {label} {label.replace('Auerbach^REMIND', 'loc')}")

            elif label.endswith('Auerbach^REMIND_1') or label.endswith('nf'): 
                session = 'nf'
                if label.endswith('Auerbach^REMIND_1'):
                    os.system(f"mv {label} {label.replace('Auerbach^REMIND_1', 'nf')}")

            # exclude marked runs
            if runs_to_exclude:
                exclude_runs(bids_ignore_runs, subject, site, session)

            # find all the zipped dicom folders, unzip them to new directory
            zip_dicom_list = list(Path(label).rglob("*dicom.[z][i][p]"))
            #unzip_dicoms(zip_dicom_list, sub_out_path, session)

    # For NEU data, folders are separated by session. There is no need to unzip, but moving files is needed
    if 'remind3' in subject:
        site = 'neu'
        old_session_labels = glob.glob(f'{main_path}/neu/*{subject}*')
        # loop through sessions
        for label in old_session_labels:
            print(label)
            if 'ses-loc' in label:
                session='loc'
            elif 'ses-nf' in label or 'ses-rt' in label:
                session='nf'
        
            if runs_to_exclude:
                if session=='loc':
                    # bids ignore runs are only ones from localizer session
                    bids_ignore_runs_session = bids_ignore_runs['ses-loc' in bids_ignore_runs]
                elif session=='nf':
                    bids_ignore_runs_session = bids_ignore_runs['ses-nf' in bids_ignore_runs]
                exclude_runs(bids_ignore_runs_session, subject, site, label)

            reorganize_data(session, label, sub_out_path)


def reorganize_data(session, label, sub_out_path):
    '''
    Function to move ONLY NEU dicom data from raw form to the dicom folder prepped for heudiconv
    '''
    for run in glob.glob(f'{label}/*'):
        cmd = f"cp -r {run} {sub_out_path}/{session}/"
        print(cmd)

def exclude_runs(run_list, subject, site, session):
    '''
    Given a list of "bad" runs to exclude - make sure these are not in the file structure to be passed to heudiconv
    '''

    # find base directories for dicom folders
    if site=='cu':
        base_path = f'{main_path}/{site}]/{subject}'
    elif site=='neu':
        base_path = f'{session}/`Whitfieldgabrieli_Bauer_1029_R61Remind - 1`'

    # loop through list of runs to exclude, finalize path, and remove folders
    for run in run_list:
        if site=='cu':
            run = run.replace('ses-nf', 'nf')
            run = run.replace('ses-loc', 'loc')
        elif site=='neu':
            run = run.split('/')[-1]
        run_path = f'{base_path}/{run}'

        # remove the excluded runs
        print(f'Removing: {run_path}')
        os.system(f'rm -rf {run_path}')

def unzip_dicoms(dicom_list, sub_out_path, session):
    '''
    Given a list of zipped dicom files, unzip them into the designated subject/session folder
    Does not unzip files set to be ignored
    '''
    ignore_keys = ['ignore-BIDS', 'Phoenix', 'MoCo', 'anat-loc']
    for dicom_zip in dicom_list:
        if not any([x in str(dicom_zip) for x in ignore_keys]):
            print(f"unzipping: {str(dicom_zip).split('/')[-2]}")
            os.system(f'unzip {dicom_zip} -d {sub_out_path}/{session}')
        else:
            print(f"IGNORE: {str(dicom_zip).split('/')[-2]}")



dicom_out_path = '/neurodata/mindful_brain_project/data/dicom_prepped_for_heudiconv'
main_path = '/neurodata/mindful_brain_project/data/dicom'

os.system(f'mkdir {dicom_out_path}')

# run for one subject! 
organize_dicoms(main_path=main_path, dicom_out_path = dicom_out_path, subject=sys.argv[1])