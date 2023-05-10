write_files=0; % set to zero to not write EV files

cd data

% subs=['*MW002*'; '*MW003*'; '*MW004*'; '*MW005*'; '*MW008*'; '*MW010*'; '*MW011*'; '*MW012*'; '*MW013*'; '*MW015*'; '*MW016*'; '*MW019*'; '*MW014*'; '*MW021*'; '*MW022*'; '*MW020*'];
subs=['*MW010*'] % for single subject, use this and comment out line above

Subs=cellstr(subs);
 
for sub=1:size(subs)

current_sub=char(Subs(sub))

files=dir(current_sub);
load(files(5,1).name);


% calculate total time
total_time=endtime-starttime;


        RT=response(:,5);
        
        % Turn zeros (COs + OEs) into NaNs
       RT(find(RT==0))=NaN;
        
        % Turn RTs for error trials (CEs) into NaNs      
        commission_error_indices=find(response(:,1)==1 & response(:,7)==-1);
        RT(commission_error_indices)=NaN;
        
        % Subtract start time from onset of each stimulus
        RT=RT(1:length(response),:);
        for x=1:length(response) 
            RT(x,2)=data(x,9)-starttime;
        end;
       % RT: column 1 = RT (time between stimulus onset and button press); column 2 = stimulus onset time
        
       
       % Calculate button press onsets
       RT_onset=RT(:,1)+RT(:,2);
        
        % Calculate mean and SD of trials with responses (correct commissions)
        meanRT=nanmean(RT(:,1));
        stdRT=nanstd(RT(:,1),1);
        
       % convert RTs to z scores (deviance from mean) and absolute z scores
       VTC=(RT(:,1)-meanRT)/stdRT;
       % abs_VTC;
       
             
  pause
        
        %interp to fill NaNs
        RT(:,4)=inpaint_nans(RT(:,3),4);
        
        
        %RT cols 1=RTs 2=time of 100% 3=RTs with NaNs 4=RTs with mean replacement
        RT(:,5)=(((RT(:,3)-meanRT)/meanRT)); % absolute threshold (group median)
        RT(:,6)=(((RT(:,4)-meanRT)/meanRT)); % absolute threshold
        
        for x=1:length(RT)
            RT(x,7)=RT(x,5)^2;      %now col 7 is Variance with Nans
            RT(x,8)=RT(x,6)^2;      %now col 8 is Variance with mean repl
            RT(x,9)=abs(RT(x,5));   %now col 7 is abs deviance with Nans
            RT(x,10)=abs(RT(x,6));  %now col 8 is abs deviance with mean repl
        end;


%% correct commissions %%

% stimulus onsets?
correct_commission_onsets=data((find(response(:,1)==2 & response(:,7)==1)+1),9)-starttime;
% RT
correct_commission_RTs=response((find(response(:,1)==2 & response(:,7)==1)),5);


%% commission errors %%

commission_errors_onsets=data((find(response(:,1)==1 & response(:,7)==-1)+1),9)-starttime;

%% correct omissions %%

correct_omission_onsets=data((find(response(:,1)==1 & response(:,7)==0)+1),9)-starttime;

%% omission errors %%

omission_onsets=data((find(response(:,1)==2 & response(:,7)==0)+1),9)-starttime;




end
