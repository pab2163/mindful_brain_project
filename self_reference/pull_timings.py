import numpy as np
import pandas as pd


# Makes stim timings for a single block within a run
def make_block_timings(block_num, pos, neg):
    # Make a 6 row dataframe with the timings of positive/negative words for a given block
    pos_frame = pd.DataFrame({'time':pos[block_num, ], 'stim_type': ['positive']*3})
    neg_frame =pd.DataFrame({'time':neg[block_num, ], 'stim_type': ['negative']*3})
    full_frame = pd.concat([pos_frame, neg_frame])

    # sort values by time
    full_frame.sort_values(by = 'time', axis = 0, inplace = True)

    # get the difference in time between each set of stimuli
    full_frame['time_diff'] = full_frame.time.diff() 

    # fixation duration is the difference in time between trials - 2.5 seconds (when the word is on the screen)
    full_frame['fix_duration'] = full_frame.time_diff - 2.5
    full_frame.reset_index(inplace = True, drop = True)

    # '0 second' fixation for the first trial in the block -- that's because the fixation is coded to be at the start of each trial
    full_frame['fix_duration'][0] = 0
    full_frame['block'] = block_num
    return(full_frame)

# Make timings for each block of the run
def make_run_timings(pos, neg):
    blocks = 10
    block_timing_list = []
    for block in range(blocks):
        block_timing_list.append(make_block_timings(block_num = block, pos = pos, neg = neg))

    # Concatenate 1 dataframe with timings for all blocks of the run
    all_block_timings = pd.concat(block_timing_list)
    return(all_block_timings)