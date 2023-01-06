#!/bin/sh

if [[ -z $MURFI_SUBJECT_NAME ]];
then
	input_string=$(zenity --forms --title="MURFI GUI" \
	--separator=" " \
	--add-entry="Participant ID" \
	--add-combo="Step" --combo-values "create|setup" \
	--cancel-label "Exit" --ok-label "Run Selected Step")
	ret=$?

	# parse zenity output using space as delimiter
	read -a input_array <<< $input_string
	partcipant_id=remind${input_array[0]}
	step=${input_array[1]}
	
else
	input_string=$(zenity --forms --title="MURFI GUI" \
	--text="PARTICIPANT NAME: ${MURFI_SUBJECT_NAME}" \
	--separator=" " \
	--add-combo="Step" --combo-values "setup|resting_state|2vol|register|extract_rs_networks|process_roi_masks|feedback" \
	--cancel-label "Exit" --ok-label "Run Selected Step")
	ret=$?
	# parse zenity output using space as delimiter
	read -a input_array <<< $input_string
	step=${input_array[0]}
	partcipant_id=$MURFI_SUBJECT_NAME
fi

echo $ret

if [[ $ret == 1 ]];
then
	exit 0
fi





# Run selected step
if [ ${step} == 'create' ]
then
	echo "source createxml.sh ${partcipant_id} setup"
	source createxml.sh ${partcipant_id} setup	
else
	echo "source feedback.sh ${partcipant_id} ${step}"
	source feedback.sh ${partcipant_id} ${step}
fi

# Re-launch script to keep MURFI GUI open 
bash launch_murfi.sh