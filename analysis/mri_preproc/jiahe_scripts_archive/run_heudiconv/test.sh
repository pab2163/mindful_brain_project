dicom_dir='/Volumes/columbia/mbNF_MDD/DATA/MRI/flywheel_dicom/flywheel/auerbach/dicom_for_bids/sub-remind2079/ses-nf'
session_dicoms=$(find "$dicom_dir" -type f -name "*.dcm")


echo "$session_dicoms"


# Extract only the filenames (basename) and sort them
file_names=$(echo "$session_dicoms" | xargs -n 1 basename | sort)

# Find duplicates using uniq
duplicates=$(echo "$file_names" | uniq -d)

# Report results
if [ -n "$duplicates" ]; then
  echo "Duplicate files found:"
  echo "$duplicates"
else
  echo "No duplicate files found."
fi