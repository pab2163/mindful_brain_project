"""Heuristic to convert dicoms to nifti in Brain Imaging Data Structure format
for the R61 realtime remind project.

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
    t2 = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_T2w')

    twovol = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-2vol_run-{item:02d}_bold')
    rest = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_run-{item:02d}_bold')
    restpre = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-restpre_run-{item:02d}_bold')
    restpost = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-restpost_run-{item:02d}_bold')
    selfref = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-selfref_run-{item:02d}_bold')
    transferpre = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-transferpre_run-{item:02d}_bold')
    transferpost = create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-transferpost_run-{item:02d}_bold')
    feedback= create_key(
        'sub-{subject}/{session}/func/sub-{subject}_{session}_task-feedback_run-{item:02d}_bold')
    # fieldmaps
    fmap_rest = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-rest_dir-{dir}_epi')
    fmap_selfref = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-selfref_dir-{dir}_epi')
    fmap_realtime = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-realtime_dir-{dir}_epi')
    fmap_restpre = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-restpre_dir-{dir}_epi')
    fmap_restpost = create_key(
        'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-restpost_dir-{dir}_epi')


    info = {
        t1: [],
        t2: [],
        twovol: [],
        rest: [],
        restpre: [],
        restpost: [],
        fmap_rest: [],
        fmap_restpre: [],
        fmap_restpost: [],
        fmap_selfref: [],
        fmap_realtime: [],
        selfref: [],
        transferpre: [],
        transferpost: [],
        feedback: []
    }

    # this section defines how heudiconv should "find" each sequence among the dicoms and match them to the keys
    for s in seqinfo:

        # T1.
        if (s.dim1, s.dim2, s.dim3, s.dim4) == (256, 256, 176, 1) and 'T1w' in s.protocol_name and not s.is_motion_corrected:
            info[t1] = [s.series_id]

        # T2.
        elif s.dim3 == 176 and s.dim4 == 1 and 'T2w' in s.protocol_name and not s.is_motion_corrected:
            info[t2].append(s.series_id)
            
        # 2vol
        elif s.dim4 == 2 and 'task-2vol' in s.protocol_name:
            info[twovol].append(s.series_id)

        # Resting state (AP and PA).
        elif s.dim4 > 100 and 'task-rest' in s.protocol_name and not s.is_motion_corrected and not 'task-restpre' in s.protocol_name and not 'task-restost' in s.protocol_name:
            info[rest].append(s.series_id)
        elif s.dim4 > 100 and 'task-restpre' in s.protocol_name and not s.is_motion_corrected:
            info[restpre].append(s.series_id)
        elif s.dim4 > 100 and 'task-restpost' in s.protocol_name and not s.is_motion_corrected:
            info[restpost].append(s.series_id)
       
        # Fieldmaps (AP and PA).
        elif 'fmap' in s.protocol_name and 'acq-rest' in s.protocol_name and not 'acq-restpre' in s.protocol_name and not 'acq_restpost' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_rest].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_rest].append({'dir': 'PA', 'item': s.series_id})

        elif 'fmap' in s.protocol_name and 'acq-restpre' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_restpre].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_restpre].append({'dir': 'PA', 'item': s.series_id})

        elif 'fmap' in s.protocol_name and 'acq-restpost' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_restpost].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_restpost].append({'dir': 'PA', 'item': s.series_id})

        elif 'fmap' in s.protocol_name and 'acq-realtime' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_realtime].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_realtime].append({'dir': 'PA', 'item': s.series_id})

        elif 'fmap' in s.protocol_name and 'acq-selfref' in s.protocol_name:
            if 'AP' in s.protocol_name:
                info[fmap_selfref].append({'dir': 'AP', 'item': s.series_id})
            elif 'PA' in s.protocol_name:
                info[fmap_selfref].append({'dir': 'PA', 'item': s.series_id})

        # self reference task.
        elif s.dim4 > 200 and 'task-selfref' in s.protocol_name:
            info[selfref].append(s.series_id)

        # transfer run pre
        elif s.dim4 > 80 and 'task-transferpre' in s.protocol_name and not s.is_motion_corrected:
            info[transferpre].append(s.series_id)

        # transfer run post
        elif s.dim4 > 80 and 'task-transferpost' in s.protocol_name and not s.is_motion_corrected:
            info[transferpost].append(s.series_id)

        # feedback
        elif s.dim4 > 80 and 'task-feedback' in s.protocol_name and not s.is_motion_corrected:
            info[feedback].append(s.series_id)

    return info

# To autopopulate the IntendedFor field in BIDS fmap json files
POPULATE_INTENDED_FOR_OPTS = {
        'matching_parameters': ['ImagingVolume', 'Shims'],
        'criterion': 'Closest'
}
