docker run -it \
   -v /neurodata/mindful_brain_project/data/fmriprep/fmriprep-23.2.1:/fmri_dir \
   -v /neurodata/mindful_brain_project/work:/work \
   -v /neurodata/mindful_brain_project/data/xcp:/output_dir \
   pennlinc/xcp_d:latest \
   /fmri_dir \
   /output_dir \
   participant \
    --participant-label sub-remind2002 \
    --work_dir /work \
    --mode none \
    --input-type fmriprep \
    --file-format nifti \
    --task-id rest \
    --fd-thresh 0.3 \
    --despike y  \
    --linc-qc y \
    --combine-runs n \
    --motion-filter-type lp \
    --band-stop-min 6 \
    --min-time 0  \
    --smoothing 4 \
    --dummy_scans auto 
