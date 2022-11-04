import numpy as np
import pandas as pd

pos = np.loadtxt('stimtime_generation/stimes_01_pos.1D')
neg = np.loadtxt('stimtime_generation/stimes_02_neg.1D')


def make_block_timings(block_num):
    pos_frame = pd.DataFrame({'time':pos[block_num, ], 'stim_type': ['positive']*3})
    neg_frame =pd.DataFrame({'time':neg[block_num, ], 'stim_type': ['negative']*3})
    full_frame = pd.concat([pos_frame, neg_frame])
    full_frame.sort_values(by = 'time', axis = 0, inplace = True)
    full_frame['time_diff'] = full_frame.time.diff() 
    full_frame['fix_duration'] = full_frame.time_diff - 2.5
    full_frame.reset_index(inplace = True, drop = True)
    full_frame['fix_duration'][0] = 0.5
    full_frame['block'] = block_num
    return(full_frame)


blocks = 10
block_timing_list = []
for block in range(blocks):
    block_timing_list.append(make_block_timings(block_num = block))


all_block_timings = pd.concat(block_timing_list)
