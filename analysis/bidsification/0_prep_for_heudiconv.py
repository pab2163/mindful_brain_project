import glob
from pathlib import Path
import os
import sys

def organize_dicoms(main_path, dicom_out_path, subject):
    '''
    Organizes dicoms pre-heudiconv for one subject
    '''
    
    sub_out_path = f'{dicom_out_path}/{subject}/'
    os.system(f'mkdir {sub_out_path}')
    os.system(f'mkdir {sub_out_path}/loc')
    os.system(f'mkdir {sub_out_path}/nf')

    # For CU data (subject id remind2###) - need to unzip dicoms
    if 'remind2' in subject:
        old_session_labels = glob.glob(f'{main_path}/cu/{subject}/*')
        for label in old_session_labels:
            print(label)
            if label.endswith('Auerbach^REMIND') or label.endswith('loc'):
                session = 'loc'
            elif label.endswith('Auerbach^REMIND_1') or label.endswith('nf'): 
                session = 'nf'
    
    
            # find all the zipped dicom folders, unzip them to new directory
            zip_dicom_list = list(Path(label).rglob("*dicom.[z][i][p]"))
            unzip_dicoms(zip_dicom_list, sub_out_path, session)

    # For NEU data, folders are separated by session. Nest them
    if 'remind3' in subject:
        pass
        
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
