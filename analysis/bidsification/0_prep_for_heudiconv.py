import glob
from pathlib import Path
import os


def organize_dicoms(main_path, dicom_out_path, subject):
    old_session_labels = glob.glob(f'{main_path}/{subject}/*')


    for label in old_session_labels:
        print(label)
        if label.endswith('Auerbach^REMIND') or label.endswith('loc'):
            session = 'loc'
        elif label.endswith('Auerbach^REMIND_1') or label.endswith('nf'): 
            session = 'nf'

            sub_out_path = f'{dicom_out_path}/{subject}/'
            os.system(f'mkdir {sub_out_path}')
            os.system(f'mkdir {sub_out_path}/loc')
            os.system(f'mkdir {sub_out_path}/nf')

        # find all the zipped dicom folders, unzip them to new directory
        zip_dicom_list = list(Path(label).rglob("*dicom.[z][i][p]"))
        unzip_dicoms(zip_dicom_list, sub_out_path, session)


def unzip_dicoms(dicom_list, sub_out_path, session):
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
organize_dicoms(main_path=main_path, dicom_out_path = dicom_out_path, subject='remind2079')
