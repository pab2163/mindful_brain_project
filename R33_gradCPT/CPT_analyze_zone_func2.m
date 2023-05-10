%playing around with CPT_analyze_zone

function [Output2,MEDIAN_VAR,ZoneTime]=CPT_analyze_zone_func2(response,data,L,quantile_low,quantile_high)

MTN=1;
CITY=2;
CORRECT=1;
ERROR=-1;
NR=0;

sub=1;

% Smoothing kernel stuff
%L=13;
if nargin<3 %if FWHM smoothing kernel unspecified, go with 20
    L=20;
end;

if nargin<4
    quantile_low=.5;
    quantile_high=.5;
end;

W=gausswin(L)/2;


    try starttime>0;
    catch
        starttime=data(1,9)-8;
    end;
    
    RT=response(:,5);
    RT=RT(1:length(response)-1,:);
    for x=1:length(response)-1
        RT(x,2)=data((x+1),9)-starttime;
    end;
    RT2=RT(find(RT(:,1)>0),:);
    
    meanRT=mean(RT2(:,1));
    stdRT=std(RT2(:,1),1);
    
    RT(:,3)=RT(:,1);
    RT(find(RT(:,3)==0),3)=NaN;
    nans = isnan(RT(:,3));
    
    %interp to fill NaNs
    RT(:,4)=inpaint_nans(RT(:,3),4);
    
    %RT cols 1=RTs 2=time of 100% 3=RTs with NaNs 4=RTs with mean replacement
    RT(:,5)=(((RT(:,3)-meanRT)/stdRT));
    RT(:,6)=(((RT(:,4)-meanRT)/stdRT));
    for x=1:length(RT)
        RT(x,7)=RT(x,5)^2;      %now col 7 is Variance with Nans
        RT(x,8)=RT(x,6)^2;      %now col 8 is Variance with mean repl
        RT(x,9)=abs(RT(x,5));   %now col 7 is abs deviance with Nans
        RT(x,10)=abs(RT(x,6));  %now col 8 is abs deviance with mean repl
    end;
    
    quart_length=round(length(RT(:,3))/4);
    for q=1:4
        if q~=4
            quart_meanRT(q)=mean(RT(1+quart_length*(q-1):quart_length*q,4));
            quart_stdRT(q)=std(RT(1+quart_length*(q-1):quart_length*q,4));
        else
            quart_meanRT(q)=mean(RT(1+quart_length*(q-1):length(RT(:,4)),4));
            quart_stdRT(q)=std(RT(1+quart_length*(q-1):length(RT(:,4)),4));
        end
    end
    %ORINIGAL VTC
    %Var_smooth{1}=filtfilt(w1,1,RT(:,8));
    Var_smooth=filtfilt(W,1,RT(:,10)); %abs 20 this is the 20VTC in trial space
    median_VTC=median(Var_smooth);
    
    
    %DTC variant
    DTC=[];
    for x=2:size(RT,1)
        DTC(x,1)=(((RT(x-1,4)-RT(x,4))^2)^.5);
    end;
    median_DTC=median(DTC);
    DTC_smooth=filtfilt(W,1,DTC);
    
    %RTC variant
    RTC=filtfilt(W,1,RT(:,4));
    median_RTC=median(RTC);
    
    %VTC local/quartile mean
    
    % VTC using means for each quartile instead of the overall mean
    for q=1:4
        if q~=4
            RT_quart(1+quart_length*(q-1):quart_length*q)=abs((RT(1+quart_length*(q-1):quart_length*q,4)-quart_meanRT(q))/quart_stdRT(q));
        else
            RT_quart(1+quart_length*(q-1):length(RT(:,4)))=abs((RT(1+quart_length*(q-1):length(RT(:,4)),4)-quart_meanRT(q))/quart_stdRT(q));
        end
    end
    VTCquart_smooth=filtfilt(W,1,RT_quart);
    median_VTCquart=median(VTCquart_smooth);
    
    %pick the version you like
    
    VARIABILITY_TC=Var_smooth;%DTC_smooth;%VTCquart_smooth;%Var_smooth;%RTC
    MEDIAN_VAR=median(VARIABILITY_TC);
    
    MEDIAN_VAR_group(sub,1)=MEDIAN_VAR;
    
    %MEDIAN_VAR=16.0102746; %VTC12 no reward group mean=5.230086562    all subs mean = 5.276916977  VTC20, no reward=16.0102746  all subs=16.13631305
    
    
    CO_Z=0;
    CO_NZ=0;
    CE_Z=0;
    CE_NZ=0;
    CC_Z=0;
    CC_NZ=0;
    OE_Z=0;
    OE_NZ=0;
    
    for t=1:length(response)-1
        if response(t,1)==MTN && response(t,7)==NR
            if VARIABILITY_TC(t)<quantile(VARIABILITY_TC,quantile_low)
                CO_Z=CO_Z+1;
            elseif VARIABILITY_TC(t)>=quantile(VARIABILITY_TC,quantile_high)
                CO_NZ=CO_NZ+1;
            end
        elseif response(t,1)==MTN && response(t,7)==ERROR
            if VARIABILITY_TC(t)<quantile(VARIABILITY_TC,quantile_low)
                CE_Z=CE_Z+1;
            elseif VARIABILITY_TC(t)>=quantile(MEDIAN_VAR,quantile_high)
                CE_NZ=CE_NZ+1;
            end
        elseif response(t,1)==CITY && response(t,7)==CORRECT
            if VARIABILITY_TC(t)<quantile(VARIABILITY_TC,quantile_low)
                CC_Z=CC_Z+1;
            elseif VARIABILITY_TC(t)>=quantile(VARIABILITY_TC,quantile_high)
                CC_NZ=CC_NZ+1;
            end
        elseif response(t,1)==CITY && response(t,7)==NR
            if  VARIABILITY_TC(t)<quantile(VARIABILITY_TC,quantile_low)
                OE_Z=OE_Z+1;
            elseif VARIABILITY_TC(t)>=quantile(VARIABILITY_TC,quantile_high)
                OE_NZ=OE_NZ+1;
            end
        end;
    end;
    
    pre_CO_Z=[];
    pre_CO_NZ=[];
    pre_CE_Z=[];
    pre_CE_NZ=[];
    CC_Z_RT=[];
    CC_NZ_RT=[];
    pre_OE_Z=[];
    pre_OE_NZ=[];
    
    if response(1,1)==CITY && response(1,7)==CORRECT
        if VARIABILITY_TC(1)<quantile(VARIABILITY_TC,quantile_low)
            CC_Z_RT=[CC_Z_RT; response(1,5)];
        elseif VARIABILITY_TC(t)>=quantile(VARIABILITY_TC,quantile_high)
            CC_NZ_RT=[CC_NZ_RT; response(1,5)];
        end
    end
    
    for t=2:length(response)-1
        if response(t-1,1)==CITY && response(t-1,7)==CORRECT
            if response(t,1)==MTN && response(t,7)==NR
                if VARIABILITY_TC(t)<quantile(VARIABILITY_TC,quantile_low)
                    pre_CO_Z=[pre_CO_Z; response(t-1,5)];
                elseif VARIABILITY_TC(t)>=quantile(VARIABILITY_TC,quantile_high)
                    pre_CO_NZ=[pre_CO_NZ; response(t-1,5)];
                end
            elseif response(t,1)==MTN && response(t,7)==ERROR
                if VARIABILITY_TC(t)<quantile(VARIABILITY_TC,quantile_low)
                    pre_CE_Z=[pre_CE_Z; response(t-1,5)];
                elseif VARIABILITY_TC(t)>=quantile(VARIABILITY_TC,quantile_high)
                    pre_CE_NZ=[pre_CE_NZ; response(t-1,5)];
                end
            elseif response(t,1)==CITY && response(t,7)==NR
                if  VARIABILITY_TC(t)<quantile(VARIABILITY_TC,quantile_low)
                    pre_OE_Z=[pre_OE_Z; response(t-1,5)];
                elseif VARIABILITY_TC(t)>=quantile(VARIABILITY_TC,quantile_high)
                    pre_OE_NZ=[pre_OE_NZ; response(t-1,5)];
                end
            end;
        end
        if response(t,1)==CITY && response(t,7)==CORRECT
            if VARIABILITY_TC(t)<quantile(VARIABILITY_TC,quantile_low)
                CC_Z_RT=[CC_Z_RT; response(t,5)];
            elseif VARIABILITY_TC(t)>=quantile(VARIABILITY_TC,quantile_high)
                CC_NZ_RT=[CC_NZ_RT; response(t,5)];
            end
        end;
    end
    
    group_CE_Z_rate(sub,1)=CE_Z/(CE_Z+CO_Z);
    group_CE_NZ_rate(sub,1)=CE_NZ/(CE_NZ+CO_NZ);
    group_OE_Z_rate(sub,1)=OE_Z/(OE_Z+CC_Z);
    group_OE_NZ_rate(sub,1)=OE_NZ/(OE_NZ+CC_NZ);
    
    group_pre_CE_Z(sub,1)=nanmean(pre_CE_Z);
    group_pre_CE_NZ(sub,1)=nanmean(pre_CE_NZ);
    group_pre_OE_Z(sub,1)=nanmean(pre_OE_Z);
    group_pre_OE_NZ(sub,1)=nanmean(pre_OE_NZ);
    group_pre_CO_Z(sub,1)=nanmean(pre_CO_Z);
    group_pre_CO_NZ(sub,1)=nanmean(pre_CO_NZ);
    group_CC_Z(sub,1)=nanmean(CC_Z_RT);
    group_CC_NZ(sub,1)=nanmean(CC_NZ_RT);
    
    group_CC_SD_Z(sub,1)=nanstd(CC_Z_RT);
    group_CC_SD_NZ(sub,1)=nanstd(CC_NZ_RT);
    
    
    pHit_Z=1-CE_Z/(CE_Z+CO_Z);
    pFA_Z=OE_Z/(OE_Z+CC_Z);
%     pHit_Z(find(pHit_Z(:)==1))=1-.5/37*2; %.5/37*2 for Z/NZ 
%     pFA_Z(find(pFA_Z(:)==0))=.5/338*2; %.5/338*2 for Z/NZ
    pHit_Z(find(pHit_Z(:)==1))=1-.5/(CE_Z+CO_Z); 
    pHit_Z(find(pHit_Z(:)==0))=.5/(CE_Z+CO_Z); 
    pFA_Z(find(pFA_Z(:)==0))=.5/(OE_Z+CC_Z); 
    pFA_Z(find(pFA_Z(:)==1))=1-.5/(OE_Z+CC_Z);
    zHIT_Z=norminv(pHit_Z);
    zFA_Z=norminv(pFA_Z);
    dprime_Z=zHIT_Z-zFA_Z;
    criterion_Z=(-1*(zHIT_Z+zFA_Z))/2;
    
    pHit_NZ=1-CE_NZ/(CE_NZ+CO_NZ);
    pFA_NZ=OE_NZ/(OE_NZ+CC_NZ);
%     pHit_NZ(find(pHit_NZ(:)==1))=1-.5/37*2; %.5/37*2 for Z/NZ 
%     pFA_NZ(find(pFA_NZ(:)==0))=.5/338*2; %.5/338*2 for Z/NZ
    pHit_NZ(find(pHit_NZ(:)==1))=1-.5/(CE_NZ+CO_NZ);
    pHit_NZ(find(pHit_NZ(:)==0))=.5/(CE_NZ+CO_NZ);
    pFA_NZ(find(pFA_NZ(:)==0))=.5/(OE_NZ+CC_NZ); 
    pFA_NZ(find(pFA_NZ(:)==1))=1-.5/(OE_NZ+CC_NZ); 
    zHIT_NZ=norminv(pHit_NZ);
    zFA_NZ=norminv(pFA_NZ);
    dprime_NZ=zHIT_NZ-zFA_NZ;
    criterion_NZ=(-1*(zHIT_NZ+zFA_NZ))/2;
    
    pHit=1-(CE_NZ+CE_Z)/(CE_NZ+CO_NZ+CE_Z+CO_Z);
    pFA=(OE_NZ+OE_Z)/(OE_NZ+CC_NZ+OE_Z+CC_Z);
%     pHit(find(pHit(:)==1))=0.9868; %.5/37
%     pFA(find(pFA(:)==0))=0.0015; %.5/338
    pHit(find(pHit(:)==1))=1-.5/(CE_Z+CE_NZ+CO_Z+CO_NZ);
    pFA(find(pFA(:)==0))=.5/(CC_Z+OE_Z+CC_NZ+OE_NZ);
    zHIT=norminv(pHit);
    zFA=norminv(pFA);
    dprime=zHIT-zFA;
    criterion=(-1*(zHIT+zFA))/2;
    
    group_dprime(sub,1)=dprime_Z;
    group_dprime(sub,2)=dprime_NZ;
    %group_dprime(sub,3)=dprime;
    group_dprime(sub,3)=criterion_Z;
    group_dprime(sub,4)=criterion_NZ;
    %group_dprime(sub,6)=criterion;
    
    

    GROUP_MEDIAN=2.9064; %fill this in with group mean of MEDIAN_VAR for between-subject zone differences rather than within
    
    for q=1:4
        if q~=4
            ZoneTime(sub,q)=size(find(VARIABILITY_TC(1+quart_length*(q-1):quart_length*q)<GROUP_MEDIAN),1)/length(1+quart_length*(q-1):quart_length*q);
        else
            ZoneTime(sub,q)=size(find(VARIABILITY_TC(1+quart_length*(q-1):length(VARIABILITY_TC))<GROUP_MEDIAN),1)/length(1+quart_length*(q-1):length(VARIABILITY_TC));
        end
    end
    ZoneTime(sub,5)=size(find(VARIABILITY_TC<GROUP_MEDIAN),1)/length(VARIABILITY_TC);
    


Output2=[group_CE_Z_rate group_CE_NZ_rate group_OE_Z_rate group_OE_NZ_rate group_CC_Z group_CC_NZ group_CC_SD_Z group_CC_SD_NZ group_dprime];