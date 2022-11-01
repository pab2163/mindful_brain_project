make_random_timing.py -num_runs 10 -run_time 24  \
    -prefix stimes                \
    -add_timing_class ISI1 0.5 -1 8		 \
    -add_timing_class word 2.5 \
    -add_stim_class pos  3  word  ISI1               \
    -add_stim_class neg  3  word  ISI1               \
    -show_timing_stats