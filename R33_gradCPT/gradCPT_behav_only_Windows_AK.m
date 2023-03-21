% Must run TTL_vs_PTB_gradCPT.m first
% For EBS, must manually create EBS_onsets.mat file (e.g. using EEGlab viewing to
% find exact onset times)

%==========================================================================
% Written by Aaron Kucyi, LBCN, Stanford University
%==========================================================================

sub=input('Subject: (XXX)','s');
ses=input('Session: (localizer/nf1/nf2/nf3/nf4)','s');
run=input('Run: (01/02)','s');
%eStim=input('EBS run? (1=yes, 0=no): ','s'); 
%run=input('Run (e.g. 1): ','s');
%delete_trials=input('Delete trials from beginning (1) or not (0)? ','s');
%if delete_trials=='1'
%   n_delete=input('Number of trials to delete: ','s'); n_delete=str2num(n_delete);
%end
baseline_color=[1 1 0];
EBS_color=[1 0 0];

save_files=1;
CPTDir=pwd
%globalECoGDir=getECoGSubDir;
% global globalECoGDir;
% Set smoothing kernel for zones
L=12; % 12 = kernel of 6 trials, if ISI=0.8 s, integrates information from ~9.6 sec (12*0.8=9.6)

%if eStim=='1'
    %cd([globalECoGDir '/gradCPT/' sub '/gradCPT_EBS/Run' run])
   
%else  
%cd([globalECoGDir '/gradCPT/' sub '/Run' run])
cd([CPTDir])
%end

%files=dir(strcat('data/',sub, '/sub-',sub,'_ses-',ses,'_task-CPT_run-',run,'_events.mat'));
load(strcat('data/',sub, '/sub-R33rtsz',sub,'_ses-',ses,'_task-CPT_run-',run,'_events.mat'));
%if delete_trials=='1'
%    response=response(n_delete+1:end,:);
%    data=data(n_delete+1:end,:);
%end

CPT_analyze_func4(response,ttt);
CV_overall=ans(44);
RT_tot=ans(19);
STD_tot=ans(24);
OE_rate=ans(14)
CE_rate=ans(9)
PTB_onsets=data(:,9)-starttime;
PTB_onsets=PTB_onsets-PTB_onsets(1);

CO_indices=find(response(:,1)==1 & response(:,2)==0);
CE_indices=find(response(:,1)==1 & response(:,2)~=0);
CC_indices=find(response(:,1)==2 & response(:,2)~=0);
OE_indices=find(response(:,1)==2 & response(:,2)==0);
CEs_total=length(CE_indices);
COs_total=length(CO_indices);

total_time=endtime-starttime;
% ECoG_start=TTL_onsets(2);

% Get RT time course
        RT=response(1:end,5); % get RTs 
     RT(find(RT==0))=NaN;    % Turn zeros (COs + OEs) into NaNs;
      RT(CE_indices)=NaN; % Turn CEs into NaNs
      
          % Subtract start time from onset of each stimulus    
 for x=1:length(RT) 
            RT(x,2)=data(x,9)-starttime;
        end;    
 stimulus_onsets_PTB=RT(:,2)-RT(1,2);
 RT=RT(:,1);
 
 % Calculate button press onsets
       RT_onset=RT+stimulus_onsets_PTB;    

        
          % Find mountain and city event onset times
mountain_ind=find(response(:,1)==1);
mountain_ind_all=mountain_ind;
        mt_dif=diff(mountain_ind); % Find and delete repeating mountain events
        mt_repeat_ind=find(mt_dif==1);
        mountain_ind(mt_repeat_ind+1)=[];
        
mountain_onsets=stimulus_onsets_PTB(mountain_ind);
city_ind=find(response(:,1)==2);
city_onsets=stimulus_onsets_PTB(city_ind);
   
% Delete repeating mountain events from CO+CE lists

CE_list=[];
for i=1:length(CE_indices)
    include=find(mountain_ind==CE_indices(i));
    if isempty(include)==0
        CE_list=[CE_list CE_indices(i)];        
    end
end

CO_list=[];
for i=1:length(CO_indices)
    include=find(mountain_ind==CO_indices(i));
    if isempty(include)==0
        CO_list=[CO_list CO_indices(i)];
    end
end

% Find onset times of stimuli with CEs and COs
        CE_onsets=[];
        CE_onsets=stimulus_onsets_PTB(CE_list);
        CO_onsets=[];
        CO_onsets=stimulus_onsets_PTB(CO_list);
        
% calculate total RTs (correct commission trials)
       Total_RTs=sum(~isnan(RT(:))); 
    
% Calculate mean and SD of trials with responses (correct commissions)
        meanRT=nanmean(RT);
        stdRT=nanstd(RT);   
  
        % Remove last trial if response was "NaN"
if isnan(RT(end))==1
    stimulus_onsets_PTB=stimulus_onsets_PTB(1:end-1);
    RT=RT(1:end-1);
    RT_onset=RT_onset(1:end-1);
end

%  % Find ECoG onset times
%     CE_onsets_ECoG=CE_onsets+ECoG_start;
%         CO_onsets_ECoG=CO_onsets+ECoG_start;
%         mountain_onsets_ECoG=mountain_onsets+ECoG_start;
%         city_onsets_ECoG=city_onsets+ECoG_start;
%         RT_onsets_ECoG=RT_onset+ECoG_start;


        
             % convert RTs to z scores (deviance from mean) and absolute z scores
       VTC=(RT-meanRT)/stdRT;
       abs_VTC=abs(VTC);  
  
       %% Get top third and bottom third high/low variability and RT (city) trials
       %low_var_ind=find(abs_VTC<nanmedian(abs_VTC)); %median split
       % high_var_ind=find(abs_VTC>nanmedian(abs_VTC)); %median spli
       low_var_ind=find(abs_VTC<prctile(abs_VTC,33.3));
       high_var_ind=find(abs_VTC>prctile(abs_VTC,66.6));
       low_var_onsets=stimulus_onsets_PTB(low_var_ind);
       high_var_onsets=stimulus_onsets_PTB(high_var_ind);
%        low_var_ECoG_onsets=low_var_onsets+ECoG_start;
%        high_var_ECoG_onsets=high_var_onsets+ECoG_start;     
       
       % low_RT_ind=find(RT<nanmedian(RT));
       % high_RT_ind=find(RT>nanmedian(RT));
       low_RT_ind=find(RT<prctile(RT,33.3));
       high_RT_ind=find(RT>prctile(RT,66.6));
       low_RT_onsets=stimulus_onsets_PTB(low_RT_ind);
       high_RT_onsets=stimulus_onsets_PTB(high_RT_ind);
%        low_RT_ECoG_onsets=low_RT_onsets+ECoG_start;
%        high_RT_ECoG_onsets=high_RT_onsets+ECoG_start;
       
       high_RT_mean=mean(RT(high_RT_ind))
       low_RT_mean=mean(RT(low_RT_ind))
       
       %% Get non-overlapping (by ~8sec) slow RT trials
       slow_diff=diff(high_RT_ind);
       
       
       %% Calculate RT/variability drift over time in sliding windows
       Window_length=60; % window length in seconds
       mean_ISI=mean(diff(PTB_onsets));
       window_size=round(Window_length/mean_ISI);
       
       for i=1:length(RT)-window_size
           window_RTs=RT(i:i+window_size-1);
           window_mean_RT=nanmean(window_RTs);
           window_std_RT=nanstd(window_RTs);
           window_CoV(i,:)=window_std_RT/window_mean_RT;
           window_mean_RTs(i,:)=window_mean_RT;
       end
       
%% Get slope of RT/variability drift
      x_meanRT=(1:length(window_mean_RTs))';
       y_meanRT=window_mean_RTs;
       coeffs_meanRT = polyfit(x_meanRT, y_meanRT, 1);
% Get fitted values
fittedX_meanRT = linspace(min(x_meanRT), max(x_meanRT), length(y_meanRT));
fittedY_meanRT = polyval(coeffs_meanRT, fittedX_meanRT);   
   
      x_CoV=(1:length(window_CoV))';
       y_CoV=window_CoV;
       coeffs_CoV = polyfit(x_CoV, y_CoV, 1);
% Get fitted values
fittedX_CoV = linspace(min(x_CoV), max(x_CoV), length(y_CoV));
fittedY_CoV = polyval(coeffs_CoV, fittedX_CoV); 
%        coefficients = polyfit(x, window_mean_RTs, 1);
%         slope = coefficients(1);
       
%% interp VTC to fill NaNs
        VTC_interp=inpaint_nans(abs_VTC);
        RT_onset_interp=inpaint_nans(RT_onset);
        
%% Smooth the VTC and divide into zones
                                
   W=gausswin(L)/2;   
   VTC_smooth=filtfilt(W,1,VTC_interp);
   norm_VTC_smooth=(VTC_smooth-mean(VTC_smooth))/std(VTC_smooth);
        
    MEDIAN_VAR=median(VTC_smooth);
Zone_TC= [];

for t=1:length(VTC_smooth)
    if VTC_smooth(t)>MEDIAN_VAR
        Zone_TC(t,:)=1; % 1 indicates out of the zone
    else
        Zone_TC(t,:)=0; % 0 indicates in the zone
    end
end

xy= abs(diff(Zone_TC)) ;
numTrans = num2str(sum(xy));    %  this calculates the number of transitions between IN & OUT of the zone
    
% RT_onsets_interp_ECoG=RT_onset_interp+ECoG_start;

% Get in- and out-of the zone epochs into ECoG time
% get indices for in and out of zone TRs
in=find(Zone_TC==0); out=find(Zone_TC==1); 
total_out_RTs=length(out); total_in_RTs=length(in);

%%% OUT OF THE ZONE %%%
jump_out=[]; jumps_out=[];

for i=2:total_out_RTs % this loop finds discontinuities within zones
    jump_out=out(i)-out(i-1);
    jumps_out(i,:)=jump_out;
end
jumps_out(1,:)=1;

% find start times for each OUT segment
out_seg_start=[]; out_seg_starts=[]; out_seg_start_RTs=[];
out_seg_start=find(jumps_out>1); out_seg_starts=[1;out_seg_start];
out_seg_start_RTs=out(out_seg_starts);

% find # of RTs in each segment
out_seg_end=[];

for j=1:total_out_RTs-1
    if jumps_out(j+1)>1
        out_seg_end(j,:)=j;
    end
end

out_seg_ends=out_seg_end(out_seg_end~=0);
out_seg_ends=[out_seg_ends;total_out_RTs(1)]; % add last segment end
out_seg_durs=out_seg_ends-out_seg_starts+1;

last_outs=out_seg_start_RTs+out_seg_durs-1;

%%% IN THE ZONE %%%
jump_in=[]; jumps_in=[];

for i=2:total_in_RTs % this loop finds discontinuities within zones
    jump_in=in(i)-in(i-1);
    jumps_in(i,:)=jump_in;
end
jumps_in(1,:)=1;

% find start TRs for each segment
in_seg_start=[]; in_seg_starts=[]; in_seg_start_RTs=[];
in_seg_start=find(jumps_in>1); in_seg_starts=[1;in_seg_start];
in_seg_start_RTs=in(in_seg_starts);

% find # of TRs in each segment
in_seg_end=[];

for j=1:total_in_RTs-1
    if jumps_in(j+1)>1
        in_seg_end(j,:)=j;
    else
    end
end

in_seg_ends=in_seg_end(in_seg_end~=0);
in_seg_ends=[in_seg_ends;total_in_RTs(1)]; % add last segment end
in_seg_durs=in_seg_ends-in_seg_starts+1;

last_ins=in_seg_start_RTs+in_seg_durs-1;

% Convert in and out of zone epochs into seconds
% start and end segments at onsets of zone transition button presses
% ECoG_out_starts=RT_onsets_interp_ECoG(out_seg_start_RTs);
% ECoG_out_stops=RT_onsets_interp_ECoG(last_outs);
% 
% ECoG_in_starts=RT_onsets_interp_ECoG(in_seg_start_RTs);
% ECoG_in_stops=RT_onsets_interp_ECoG(last_ins);
 
  
  
  %% Plots
  FigHandle = figure('Position', [200, 50, 1049, 895]);

subplot(6,1,1)
plot(stimulus_onsets_PTB, RT);   
title(['Trial-by-Trial RT; Sub = ' sub] , 'Fontsize', 12)
ylabel(['RT'])
xlabel('time in seconds')
axis([0,stimulus_onsets_PTB(end)+4,0,2.5])     % axis([xmin,xmax,ymin,ymax])

subplot(6,1,2)
plot(RT_onset, abs_VTC);   
title(['VTC (with errors); Sub = ' sub] , 'Fontsize', 12)
ylabel(['RT deviation'])
xlabel('time in seconds')
axis([0,stimulus_onsets_PTB(end)+4,0,4])     % axis([xmin,xmax,ymin,ymax])

subplot(6,1,3)
plot(RT_onset_interp, VTC_interp);    
title(['VTC (errors interpolated); Sub = ' sub] , 'Fontsize', 12)
ylabel(['RT deviation'])
xlabel('time in seconds')
axis([0,stimulus_onsets_PTB(end)+4,0,4])     % axis([xmin,xmax,ymin,ymax])

subplot(6,1,4)
plot(RT_onset_interp, norm_VTC_smooth);
title(['Smoothed VTC; Sub = ' sub] , 'Fontsize',12)
ylabel(['RT deviation'])
xlabel('time in seconds')
axis([0,stimulus_onsets_PTB(end)+4,-10,10])

subplot(6,1,5)
plot(RT_onset_interp,Zone_TC)
title(['Zone time course (0 = in-thezone, 1 = out-of-thezone;   transitions =  ' numTrans],'Fontsize',12)
ylabel(['Zone'])
xlabel('time in seconds')
axis([0,stimulus_onsets_PTB(end)+4,-0.5,1.5])
pause;close;

figure(1)
plot(fittedX_meanRT, fittedY_meanRT,'r-',x_meanRT,y_meanRT,'b-');
title(['RT Drift and line of best fit']);
pause;close;

figure(1)
plot(fittedX_CoV, fittedY_CoV,'r-',x_CoV,y_CoV,'b-');
title(['RT CoV drift and line of best fit']);
pause;close;


%mountain_repeats=length(mt_repeat_ind)
total_mountains_no_repeat=length(mountain_ind)
mt_rate=length(mountain_ind_all)/(length(mountain_ind_all)+length(city_ind))
CEs_total
run_duration=(data(end,9)-data(1,9))/60


  
        