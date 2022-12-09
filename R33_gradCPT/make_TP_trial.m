%script to make city-mountain gradCPT "supertrial" for though probes

function [list]= make_TP_trial(Rate,HoldTime,framesper,trial_length)

ClockRandSeed;

%Rate, HoldTime and framesper come from params of gradCPT
% trial_length can be 1,2, or 3, corresponding to 44 sec, 52, sec, or 60
% seconds = short, medium, long

trial_length_list=[44 52 60]; % in seconds
%convert to number of trials and round down
trial_number_list=floor(trial_length_list./(Rate*(framesper-1)+HoldTime));
%choose the number of trials for this TP supertrial
trial_number=trial_number_list(trial_length);

%3 phases of supertrial- 
%phase 1= all but last 32 seconds, ~13% mnt; 
%phase 2, lasts 20 seconds, ~8% mnt
%phase 3, lasts 12 seconds, 0 mnts

%number of trials per phase
trials_per_phase=round([(trial_number-32/(Rate*(framesper-1)+HoldTime)) 20/(Rate*(framesper-1)+HoldTime) 12/(Rate*(framesper-1)+HoldTime)]);
%if case of rounding error, add or subtract from phase 1
if sum(trials_per_phase)<trial_number
    trials_per_phase(1)=trials_per_phase(1)+1;
elseif sum(trials_per_phase)>trial_number
    trials_per_phase(1)=trials_per_phase(1)-1;
end;
%number of targets per phase
mnts_per_phase=round(trials_per_phase.*[.13 .08 0]);
%make random list of cities (2) and mnts (1) for each phase and appends to
%make'list'
list=[];
for p=1:3
    list_temp=Shuffle([ones(trials_per_phase(p)-mnts_per_phase(p),1)*2;ones(mnts_per_phase(p),1)]);
    list=[list;list_temp];
end;
%make last trial a scramble
list(size(list,1),1)=0;

