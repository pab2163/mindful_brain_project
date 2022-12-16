import nibabel as nb
import numpy as np


dmn_paths = ['../../subjects/sub-R61MBNFD999/mask/mni/dmn_mni.nii.gz',
             '/home/auerbachlinux/murfi-rt-PyProject/subjects/mia-test/mask/mni/dmn_mni.nii.gz',
             '/home/auerbachlinux/murfi-rt-PyProject/subjects/sub-R61MBNFD998/mask/mni/dmn_mni.nii.gz',
             '/home/auerbachlinux/murfi-rt-PyProject/subjects/sub-test/mask/mni/dmn_mni.nii.gz']


cen_paths = ['../../subjects/sub-R61MBNFD999/mask/mni/cen_mni.nii.gz',
             '/home/auerbachlinux/murfi-rt-PyProject/subjects/mia-test/mask/mni/cen_mni.nii.gz',
             '/home/auerbachlinux/murfi-rt-PyProject/subjects/sub-R61MBNFD998/mask/mni/cen_mni.nii.gz',
             '/home/auerbachlinux/murfi-rt-PyProject/subjects/sub-test/mask/mni/cen_mni.nii.gz']


def get_voxel_number(img_path):
    img = nb.load(img_path)
    
    # how many non-zero voxels?
    num_vox = np.sum(np.asanyarray(img.dataobj)> 0)
    
    return(num_vox)
    

print('DMN')
for path in dmn_paths:
    print(path, get_voxel_number(img_path = path))


print('CEN')
for path in cen_paths:
    print(path, get_voxel_number(img_path = path))
