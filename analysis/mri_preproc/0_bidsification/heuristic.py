"""Heuristic to convert dicoms to nifti in Brain Imaging Data Structure format
for the R61 realtime remind project.

Drafted by Jiahe Zhang, updated by Paul Bloom, Jamaal Spence, Emma Wool

Use this heuristic with [heudiconv](https://github.com/nipy/heudiconv).


Scanning paradigm and session names
-----------------

    - Session 1: loc
    - Session 2: nf

"""


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return (template, outtype, annotation_classes)


def infotodict(seqinfo):
    """Heuristic evaluator for determining which items belong where

    allowed template fields - follow python string module:

    item: index within category
    subject: participant id
    seqitem: item number during scanning
    subindex: sub index within group
    """

    t1 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_T1w')

    twovol_run_1 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-2vol_run-01_bold')
    rest_run_1 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_run-01_bold')
    rest_run_2 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_run-02_bold')
    restpre_run_1 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-restpre_run-01_bold')
    restpre_run_2 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-restpre_run-02_bold')
    restpost_run_1 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-restpost_run-01_bold')
    restpost_run_2 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-restpost_run-02_bold')
    selfref_run_1 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-selfref_run-01_bold')
    selfref_run_2 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-selfref_run-02_bold')
    transferpre_run_1 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-transferpre_run-01_bold')
    transferpost_run_1 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-transferpost_run-01_bold')
    transferpost_run_2 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-transferpost_run-02_bold')
    feedback_run_1 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-01_bold')
    feedback_run_2 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-02_bold')
    feedback_run_3 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-03_bold')
    feedback_run_4 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-04_bold')
    feedback_run_5 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-05_bold')   
    feedback_run_6 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-06_bold')
    feedback_run_7 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-07_bold')
    feedback_run_8 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-08_bold')
    feedback_run_9 = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-09_bold')
    feedback_run_10= create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-10_bold')    
           
    # fieldmaps (AP)
    fmap_rest_ap = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-rest_dir-AP_run-{item:02d}_epi')
    fmap_selfref_ap = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-selfref_dir-AP_run-{item:02d}_epi')
    fmap_realtime_ap = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-realtime_dir-AP_run-{item:02d}_epi')
    fmap_restpre_ap = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-restpre_dir-AP_run-{item:02d}_epi')
    fmap_restpost_ap = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-restpost_dir-AP_run-{item:02d}_epi')

    # fieldmaps (PA)
    fmap_rest_pa = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-rest_dir-PA_run-{item:02d}_epi')
    fmap_selfref_pa = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-selfref_dir-PA_run-{item:02d}_epi')
    fmap_realtime_pa= create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-realtime_dir-PA_run-{item:02d}_epi')
    fmap_restpre_pa = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-restpre_dir-PA_run-{item:02d}_epi')
    fmap_restpost_pa = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-restpost_dir-PA_run-{item:02d}_epi')


    info = {
        t1: [],
        twovol_run_1: [],
        rest_run_1: [],
        rest_run_2: [],
        restpre_run_1: [],
        restpre_run_2: [],
        restpost_run_1: [],
        restpost_run_2: [],        
        fmap_rest_ap: [],
        fmap_restpre_ap: [],
        fmap_restpost_ap: [],
        fmap_selfref_ap: [],
        fmap_realtime_ap: [],
        fmap_rest_pa: [],
        fmap_restpre_pa: [],
        fmap_restpost_pa: [],
        fmap_selfref_pa: [],
        fmap_realtime_pa: [],
        selfref_run_1: [],
        selfref_run_2: [],
        transferpre_run_1: [],
        transferpost_run_1: [],
        transferpost_run_2: [],
        feedback_run_1: [],
        feedback_run_2: [],
        feedback_run_3: [],
        feedback_run_4: [], 
        feedback_run_5: [], 
        feedback_run_6: [], 
        feedback_run_7: [], 
        feedback_run_8: [], 
        feedback_run_9: [],   
        feedback_run_10: []
    }

    # this section defines how heudiconv should "find" each sequence among the dicoms and match them to the keys
    for s in seqinfo:
        # T1. (sometimes 2 copies of the T1w come off the scanner. we only use the copy of the T1 marked with "NORM" - bias correction)
        if (s.dim1, s.dim2, s.dim3, s.dim4) == (256, 256, 176, 1) and 'T1w' in s.protocol_name and not s.is_motion_corrected and 'NORM' in s.image_type:
            info[t1] = [s.series_id]
            
        # 2vol
        elif s.dim4 == 2 and 'task-2vol' in s.protocol_name:
            info[twovol_run_1].append(s.series_id)

        # Resting state (localizer)
        elif s.dim4 > 100 and 'task-rest' in s.protocol_name and not s.is_motion_corrected and not 'task-restpre' in s.protocol_name and not 'task-restpost' in s.protocol_name:
            if 'run-01' in s.protocol_name or 'run01' in s.protocol_name:
                info[rest_run_1].append(s.series_id)
            elif 'run-02' in s.protocol_name or 'run02' in s.protocol_name:
                info[rest_run_2].append(s.series_id)
                
        # Resting state (pre-nf)
        elif s.dim4 > 100 and 'task-restpre' in s.protocol_name and not s.is_motion_corrected:
            if 'run-01' in s.protocol_name or 'run01' in s.protocol_name:
                info[restpre_run_1].append(s.series_id)
            elif 'run-02' in s.protocol_name or 'run02' in s.protocol_name:
                info[restpre_run_2].append(s.series_id)

        # Resting state (post-nf)
        elif s.dim4 > 100 and 'task-restpost' in s.protocol_name and not s.is_motion_corrected:
            if 'run-01' in s.protocol_name or 'run01' in s.protocol_name:
                info[restpost_run_1].append(s.series_id)
            elif 'run-02' in s.protocol_name or 'run02' in s.protocol_name:
                info[restpost_run_2].append(s.series_id)
       
        # self reference task.
        elif s.dim4 > 100 and 'task-selfref' in s.protocol_name and ('run-01' in s.protocol_name or 'run01' in s.protocol_name):
            info[selfref_run_1].append(s.series_id)

        elif s.dim4 > 100 and 'task-selfref' in s.protocol_name and ('run-02' in s.protocol_name or 'run02' in s.protocol_name):
            info[selfref_run_2].append(s.series_id)

        # transfer run pre
        elif s.dim4 > 80 and 'task-transferpre' in s.protocol_name and not s.is_motion_corrected:
            info[transferpre_run_1].append(s.series_id)

        # transfer run post
        elif s.dim4 > 80 and 'task-transferpost' in s.protocol_name and not s.is_motion_corrected:
            if 'run-01' in s.protocol_name or 'run01' in s.protocol_name:
                info[transferpost_run_1].append(s.series_id)
            elif 'run-02' in s.protocol_name or 'run02' in s.protocol_name:
                info[transferpost_run_2].append(s.series_id)

        # feedback
        elif s.dim4 > 80 and 'task-feedback' in s.protocol_name and not s.is_motion_corrected:
            if 'run-01' in s.protocol_name or 'run01' in s.protocol_name and not 'run10' in s.protocol_name:
                info[feedback_run_1].append(s.series_id)
            elif 'run-02' in s.protocol_name or 'run02' in s.protocol_name:
                info[feedback_run_2].append(s.series_id)
            elif 'run-03' in s.protocol_name or 'run03' in s.protocol_name:
                info[feedback_run_3].append(s.series_id)
            elif 'run-04' in s.protocol_name or 'run04' in s.protocol_name:
                info[feedback_run_4].append(s.series_id)
            elif 'run-05' in s.protocol_name or 'run05' in s.protocol_name:
                info[feedback_run_5].append(s.series_id)
            elif 'run-06' in s.protocol_name or 'run06' in s.protocol_name:
                info[feedback_run_6].append(s.series_id)
            elif 'run-07' in s.protocol_name or 'run07' in s.protocol_name:
                info[feedback_run_7].append(s.series_id)
            elif 'run-08' in s.protocol_name or 'run08' in s.protocol_name:
                info[feedback_run_8].append(s.series_id)
            elif 'run-09' in s.protocol_name or 'run09' in s.protocol_name:
                info[feedback_run_9].append(s.series_id)
            elif 'run-10' in s.protocol_name or 'run10' in s.protocol_name:
                info[feedback_run_10].append(s.series_id)
            
        # Fieldmaps (AP and PA). Note, AP/PA need to be defined distinctly so as to be numbered correctly in AP/PA pairs. 
        elif 'fmap' in s.protocol_name and 'rest' in s.protocol_name and not 'restpre' in s.protocol_name and not 'restpost' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_rest_ap].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_rest_pa].append({'dir': 'PA', 'item': s.series_id})

        elif 'fmap' in s.protocol_name and 'restpre' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_restpre_ap].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_restpre_pa].append({'dir': 'PA', 'item': s.series_id})

        elif 'fmap' in s.protocol_name and 'restpost' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_restpost_ap].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_restpost_pa].append({'dir': 'PA', 'item': s.series_id})

        elif 'fmap' in s.protocol_name and 'realtime' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_realtime_ap].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_realtime_pa].append({'dir': 'PA', 'item': s.series_id})

        elif 'fmap' in s.protocol_name and 'selfref' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_selfref_ap].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_selfref_pa].append({'dir': 'PA', 'item': s.series_id})

    return info

# To autopopulate the IntendedFor field in BIDS fmap json files
POPULATE_INTENDED_FOR_OPTS = {
        'matching_parameters': ['ImagingVolume', 'Shims'],
        'criterion': 'Closest'
}
