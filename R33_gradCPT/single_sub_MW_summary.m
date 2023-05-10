write_files=0; % set to zero to not write EV files

cd data

% subs=['*MW002*'; '*MW003*'; '*MW004*'; '*MW005*'; '*MW008*'; '*MW010*'; '*MW011*'; '*MW012*'; '*MW013*'; '*MW015*'; '*MW016*'; '*MW019*'; '*MW014*'; '*MW021*'; '*MW022*'; '*MW020*'];
subs=['*MW020*'] % for single subject, use this and comment out line above

Subs=cellstr(subs);
 
for sub=1:size(subs)

current_sub=char(Subs(sub))

files=dir(current_sub);
run1=load(files(1,1).name);
run2=load(files(2,1).name); 
run3=load(files(3,1).name); 
run4=load(files(4,1).name);

run1_TPs=run1.TP_Results(:,1); run1meanTPs=num2str(mean(run1_TPs));
run2_TPs=run2.TP_Results(:,1); run2meanTPs=num2str(mean(run2_TPs));
run3_TPs=run3.TP_Results(:,1); run3meanTPs=num2str(mean(run3_TPs));
run4_TPs=run4.TP_Results(:,1); run4meanTPs=num2str(mean(run4_TPs));

% normalize MW values across all runs
all_runs_TPs=[run1_TPs;run2_TPs;run3_TPs;run4_TPs];
mean_all_runs=mean(all_runs_TPs);
sd_all_runs=std(all_runs_TPs);
run1_TPs_norm=(run1_TPs-mean_all_runs)/sd_all_runs;
run2_TPs_norm=(run2_TPs-mean_all_runs)/sd_all_runs;
run3_TPs_norm=(run3_TPs-mean_all_runs)/sd_all_runs;
run4_TPs_norm=(run4_TPs-mean_all_runs)/sd_all_runs;

run_trials=[1:9]';
all_trials=[1:36]';

% find TP onset times

for TP=1:9
    TP_onset_run1=run1.ttt(run1.end_trials(TP),24)+run1.Rate-run1.starttime;
    TP_onsets_run1(TP,:)=TP_onset_run1;   
    supertrial_duration_run1(TP,:)=run1.ttt(run1.end_trials(TP),24)-run1.ttt(run1.start_trials(TP),1);
    
    
    TP_onset_run2=run2.ttt(run2.end_trials(TP),24)+run2.Rate-run2.starttime;
    TP_onsets_run2(TP,:)=TP_onset_run2;
    supertrial_duration_run2(TP,:)=run2.ttt(run2.end_trials(TP),24)-run2.ttt(run2.start_trials(TP),1);
    
    TP_onset_run3=run3.ttt(run3.end_trials(TP),24)+run3.Rate-run3.starttime;
    TP_onsets_run3(TP,:)=TP_onset_run3;
    supertrial_duration_run3(TP,:)=run3.ttt(run3.end_trials(TP),24)-run3.ttt(run3.start_trials(TP),1);
    
    TP_onset_run4=run4.ttt(run4.end_trials(TP),24)+run4.Rate-run4.starttime;
    TP_onsets_run4(TP,:)=TP_onset_run4;
    supertrial_duration_run4(TP,:)=run4.ttt(run4.end_trials(TP),24)-run4.ttt(run4.start_trials(TP),1);
end

% determine duration of TP+meta screens
TP_dur_run1=run1.TP_Results(:,2); Meta_dur_run1=run1.TP_Results(:,5);
run1_probe_durations=TP_dur_run1+Meta_dur_run1;

TP_dur_run2=run2.TP_Results(:,2); Meta_dur_run2=run2.TP_Results(:,5);
run2_probe_durations=TP_dur_run2+Meta_dur_run2;

TP_dur_run3=run3.TP_Results(:,2); Meta_dur_run3=run3.TP_Results(:,5);
run3_probe_durations=TP_dur_run3+Meta_dur_run3;

TP_dur_run4=run4.TP_Results(:,2); Meta_dur_run4=run4.TP_Results(:,5);
run4_probe_durations=TP_dur_run4+Meta_dur_run4;

% plots
FigHandle = figure('Position', [200, 50, 1049, 895]);
subplot(5,1,1)
plot(run_trials, run1_TPs, 'r.-');    
title(['Run 1 MW; Mean = ' run1meanTPs] , 'Fontsize', 12)
ylabel(['MW'])
xlabel('Trial #')
axis([0.5,9.5,0,100])     % axis([xmin,xmax,ymin,ymax])


subplot(5,1,2)
plot(run_trials, run2_TPs, 'r.-');    
title(['Run 2 MW; Mean = ' run2meanTPs] , 'Fontsize', 12)
ylabel(['MW'])
xlabel('Trial #')
axis([0.5,9.5,0,100])     % axis([xmin,xmax,ymin,ymax])

subplot(5,1,3)
plot(run_trials, run3_TPs, 'r.-');    
title(['Run 3 MW; Mean = ' run3meanTPs] , 'Fontsize', 12)
ylabel(['MW'])
xlabel('Trial #')
axis([0.5,9.5,0,100])     % axis([xmin,xmax,ymin,ymax])

subplot(5,1,4)
plot(run_trials, run4_TPs, 'r.-');    
title(['Run 4 MW; Mean = ' run4meanTPs] , 'Fontsize', 12)
ylabel(['MW'])
xlabel('Trial #')
axis([0.5,9.5,0,100])     % axis([xmin,xmax,ymin,ymax])

pause 
close

% Make FSL EVs with normalized TP values

MW_period=10; % preprobe duration (sec) of interest
MW_duration(1:9)=MW_period;

MW_EV_run1=[TP_onsets_run1-MW_period MW_duration' run1_TPs_norm];
MW_EV_run2=[TP_onsets_run2-MW_period MW_duration' run2_TPs_norm];
MW_EV_run3=[TP_onsets_run3-MW_period MW_duration' run3_TPs_norm];
MW_EV_run4=[TP_onsets_run4-MW_period MW_duration' run4_TPs_norm];

% Make FSL EV files for thought probe/meta periods
probe_weight(1:9)=1;

probe_EV_run1=[TP_onsets_run1 run1_probe_durations probe_weight'];
probe_EV_run2=[TP_onsets_run2 run2_probe_durations probe_weight'];
probe_EV_run3=[TP_onsets_run3 run3_probe_durations probe_weight'];
probe_EV_run4=[TP_onsets_run4 run4_probe_durations probe_weight'];

% Write EV files to FSL_EVs folder

if write_files==1  
    subject=current_sub(2:6);
    
    filename_MW_run1 = ['FSL_EVs/' subject '_MW_EV_run1.txt'] ; 
    dlmwrite(filename_MW_run1, MW_EV_run1, '\t') ;
    
    filename_MW_run2 = ['FSL_EVs/' subject '_MW_EV_run2.txt'] ; 
    dlmwrite(filename_MW_run2, MW_EV_run2, '\t') ;
    
    filename_MW_run3 = ['FSL_EVs/' subject '_MW_EV_run3.txt'] ; 
    dlmwrite(filename_MW_run3, MW_EV_run3, '\t') ;
    
    filename_MW_run4 = ['FSL_EVs/' subject '_MW_EV_run4.txt'] ; 
    dlmwrite(filename_MW_run4, MW_EV_run4, '\t') ;
    
    filename_probe_run1 = ['FSL_EVs/' subject '_probe_EV_run1.txt'] ; 
    dlmwrite(filename_probe_run1, probe_EV_run1, '\t') ;
    
    filename_probe_run2 = ['FSL_EVs/' subject '_probe_EV_run2.txt'] ; 
    dlmwrite(filename_probe_run2, probe_EV_run2, '\t') ;
    
    filename_probe_run3 = ['FSL_EVs/' subject '_probe_EV_run3.txt'] ; 
    dlmwrite(filename_probe_run3, probe_EV_run3, '\t') ;
    
    filename_probe_run4 = ['FSL_EVs/' subject '_probe_EV_run4.txt'] ; 
    dlmwrite(filename_probe_run4, probe_EV_run4, '\t') ;
    
else
end

end
