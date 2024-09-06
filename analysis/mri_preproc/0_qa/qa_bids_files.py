import json
import re 
import os
import glob

def update_json(fname):
    # read in json file to a dictionary
    with open(fname, 'r') as openfile:
        # Reading from json file
        sidecar_data = json.load(openfile)


    # if in the func folder, needs a task label
    if os.path.basename(os.path.dirname(fname)) == 'func':
        taskname = re.search(r'task-(.*?)_run-', fname).group(1)
        sidecar_data['TaskName']=taskname


    '''
    If repetition times or echo times are in milliseconds, convert them to seconds
    '''
    if sidecar_data['RepetitionTime']==1200:
        print(f"Converting TR from {sidecar_data['RepetitionTime']}ms to 1.2s")
        sidecar_data['RepetitionTime']=1.2

    if sidecar_data['EchoTime']==30:
        print(f"Converting TR from {sidecar_data['EchoTime']}ms to 0.03s")
        sidecar_data['EchoTime']=.03


    # Serializing json
    json_out = json.dumps(sidecar_data, indent=4)
     
    # Writing back out to the original json file (overwrites!)
    with open(fname, "w") as outfile:
        outfile.write(json_out)



# find all bids json files recursively 
files = glob.glob('../../../../DATA/test_bids/**/*.json', recursive=True)


skip_files = ['../../../../DATA/test_bids/curate-bids-session-config.json', 
    '../../../../DATA/test_bids/curate-bids-project-config.json',
    '../../../../DATA/test_bids/reproin-case3-extension.json',
    '../../../../DATA/test_bids/curate-bids-subject-config.json',
    '../../../../DATA/test_bids/dataset_description.json']

# loop through json files, run update json function
for json_file in files:
    if json_file not in skip_files:
        update_json(fname=json_file)

