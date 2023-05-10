#!/bin/tcsh
set iterations  = 100        # number of iterations to compare

mkdir stim_results


----------------------------------------------
# execution parameters
set tr          = 1.2   # used in 3dDeconvolve, if not make_random_timing.py
#set outdir      = stim_results/max_consec3_ISI_max_8.$seed  # directory that all results are under

# set pattern   = LC            # search pattern for LC[0], say
set pattern     = 'norm. std.'  # search pattern for normalized stdev vals
# "In a nutshell, the normalized standard deviation is the square root of the measurement error variance. 
#Since this variance is unknown, we estimate it with the Mean Square Error (MSE). 
#A smaller normalized standard deviation indicates a smaller MSE. 
#A small MSE is desirable, because MSE relates to the unexplained portion of the variance. 
#Unexplained variance is NOT good. Therefore, the smaller the MSE (or normalized standard deviation), the better."

# ===========================================================================
# start the work
# ===========================================================================

# ------------------------------------------------------------
# recreate $outdir each time

foreach max_consec ( 2 3 )
   foreach max_isi ( 6 8 )
      foreach run_length (30 32 36)
         set seed  = $1       # initial random seed
         set outdir=stim_results/maxconsec-${max_consec}_isimax-${max_isi}_blockdur-${run_length}-seed-$seed
         # file to store norm. std. dev. sums in
         set LCfile = NSD_sums_maxconsec-${max_consec}_isimax-${max_isi}_blockdur-${run_length}      


         if ( -d $outdir ) then
            echo "** removing output directory, $outdir ..."
            \rm -fr $outdir
         endif

         echo "++ creating output directory, $outdir ..."
         mkdir $outdir
         if ( $status ) then
            echo "failure, cannot create output directory, $outdir"
            exit
         endif

         # move into the output directory and begin work
         cd $outdir

         # create empty LC file
         echo -n "" > $LCfile

         echo -n "iteration (of $iterations): 0000"

         # ------------------------------------------------------------
         # run the test many times

         foreach iter (`count -digits 4 1 $iterations`)

            make_random_timing.py -num_runs 10 -run_time $run_length  \
               -tr $tr \
               -pre_stim_rest 0 -post_stim_rest 8 \
               -rand_post_stim_rest no                 \
               -prefix stimes.$iter               \
               -max_consec $max_consec $max_consec                         \
               -add_timing_class ISI1 0.5 -1 $max_isi		 \
               -add_timing_class word 2.5 2.5 2.5 basis=GAM \
               -add_stim_class pos_${iter}  3  word  ISI1               \
               -add_stim_class neg_${iter}  3  word  ISI1               \
               -show_timing_stats \
               -save_3dd_cmd cmd.3dd.$iter												\
                                    >& out.mrt.$iter

                                                         

                  # consider: sed 's/GAM/"TENT(0,15,7)"/' tempfile > cmd.3dd.$iter
                  #           rm -f tempfile

                  # now evaluate the stimulus timings

                  tcsh cmd.3dd.$iter >& out.3dD.$iter

                  # save the sum of the 3 LC values
                  set nums = ( `awk -F= '/'"$pattern"'/ {print $2}' out.3dD.${iter}` )

                  # make a quick ccalc command
                  set sstr = $nums[1]
                  foreach num ( $nums[2-] )
                        set sstr = "$sstr + $num"
                  end
                  set num_sum = `ccalc -expr "$sstr"`

                  echo -n "$num_sum = $sstr : " >> $LCfile
                  echo    "iteration $iter, seed $seed"                  >> $LCfile

                  echo -n "\b\b\b\b\b\b\b$iter"

                  # make some other random seed
                  @ seed = $seed + 1

         
         end

         echo ""
         echo "done, results are in '$outdir', LC sums are in '$LCfile'"
         echo consider the command: "sort -n $outdir/$LCfile | head -1"

         # note that if iter 042 seems to be the best, consider these commands:
         #
         # cd stim_results
         # set iter = 042
         # timing_tool.py -multi_timing stimes.${iter}_0*                  \
         #                -run_len $run_lengths -multi_stim_dur $stim_durs \
         #                -multi_show_isi_stats
         # tcsh cmd.3dd.$iter
         # 1dplot X.xmat.1D'[6..$]'
         # 1dplot sum_ideal.1D
         #
         # - timing_tool.py will give useful statistics regarding ISI durations
         #   (should be similar to what is seen in output file out.mrt.042)
         # - run cmd.3dd.$iter to regenerate that X martix (to create actual regressors)
         # - the first 1dplot command will show the actual regressors
         #   (note that 6 = 2*$num_runs)
         # - the second will plot the sum of the regressor (an integrity check)
         #   (note that sum_ideal.1D is produced by cmd.3dd.$iter, along with X.xmat.1D)

         cd ../../
      end
   end
end

