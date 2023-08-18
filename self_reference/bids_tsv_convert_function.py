'''
Paul Alexander Bloom
July 13 2023

Runs upon exit of SRET task (whether in the middle or at the end) to convert the csv output to a BIDS-compatible tsv file

'''

import pandas as pd
import numpy as np

def convert_sret_csv_to_bids(infile):
    
    # Durations of events hard-coded based on task design
    block_duration=28
    response_duration=0 # will indicate a delta "impulse response" function
    presentation_duration=2.5
    block_type_instruction_duration=2

    # Read in csv file
    df = pd.read_csv(infile)

    # Drop rows without a block number (i.e. during practice, fixation crosses)
    df = df.dropna(subset='block_number', axis ='rows')

    # Code duration based on the trial type (block_start, word_presentation, response, or block_type_instruction_duration)
    df['duration'] = np.where(df.trial_type=='block_start', block_duration, 
                             np.where(df.trial_type=='word_presentation', presentation_duration, 
                             np.where(df.trial_type=='response', response_duration, block_type_instruction_duration)))
    
    # Recode for a clear marking of whether participants endorsed a word
    df.response_endorse.replace({1:'endorse_y', 0:'endorse_n'}, inplace=True)

    # BIDS compliant subid
    df.participant = "sub-" + df.participant.astype(str)

    # Recode trial type to be informative for various potential designs
    df['trial_type'] = np.where(df.trial_type=='block_start', df.condition, 
                             np.where(df.trial_type=='word_presentation', df.word_valence, 
                             np.where(df.trial_type=='response', df.response_endorse, 'block_type_instruction')))
    # Rename columns
    df.rename(columns ={'trigger_time':'onset', 
                        'trial_num':'trial_number',
                        'condition':'block_type'}, inplace=True)

    # Use BIDS-compliant 'n/a' for missing values
    df.loc[df.response_time.isna(), 'response_time'] = 'n/a'
    df.loc[df.trial_number.isna(), 'trial_number'] = 'n/a'
    df.loc[df.word_valence.isna(), 'word_valence'] = 'n/a'
    df.loc[df.word.isna(), 'word'] = 'n/a'
    df.loc[df.response_endorse.isna(), 'response_endorse'] = 'n/a'
    

    # Order colunmns for output
    out_df = df[['onset', 'duration', 'trial_type', 'trial_number',
                 'response_time', 'word', 'word_valence', 'block_type', 'block_number',
                'participant', 'session', 'exp_name', 'frame_rate']]

    # Write to tsv
    out_df.to_csv(infile.replace('csv', 'tsv'), sep ='\t', index=False)
