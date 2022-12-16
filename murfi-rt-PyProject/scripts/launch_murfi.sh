#!/bin/sh

input_string=$(zenity --forms --title="Launch Murfi" \
	--separator=" " \
	--add-entry="Participant ID" \
	--add-combo="Step" --combo-values "create|setup|resting_state|2vol|register|extract_rs_networks|process_roi_masks|feedback")


# parse zenity output using space as delimiter
read -a input_array <<< $input_string
partcipant_id=${input_array[0]}
step=${input_array[1]}


export MURFI_SUBJECTS_DIR=../subjects/
export MURFI_SUBJECT_NAME=$participant_id

if [ ${step} == 'create' ]
then
	source createxml.sh ${partcipant_id} setup
else
	# run feedback.sh using zenity outputs
	#source feedback.sh ${partcipant_id} setup
	source feedback.sh ${partcipant_id} ${step}
fi

# if [ ${step} == 'Resting' ]
# then
# 		echo 'REST'
# 		input_string=$(zenity --forms --title="Choose Resting State Run #" \
# 	--separator=" " \
# 	--add-entry="Participant ID" \
# 	--add-combo="Step" --combo-values "Resting|Run ICA|Create Masks|2 Volume|Register Masks|Feedback")


# fi



