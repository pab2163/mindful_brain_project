function [Output]=CPT_analyze_func2(response,ttt)

%Analysis of CPT data


%commissions

commission_errors=size(find(response(:,1)==1 & response(:,2)~=0),1);
correct_omission=size(find(response(:,1)==1 & response(:,2)==0),1);
commission_rate=commission_errors/(correct_omission+commission_errors);


%omissions

omission_errors=size(find(response(:,1)==2 & response(:,2)==0),1);
correct_response=size(find(response(:,1)==2 & response(:,2)~=0),1);
omission_rate=omission_errors/(correct_response+omission_errors);

%errors

error_rate=(omission_errors+commission_errors)/(correct_response+omission_errors+commission_errors+correct_omission);


%RT of correct responses

meanRT=mean(response(find(response(:,5)~=0 & response(:,1)==2),5));

%STD of correct responses

STD_RT=std(response(find(response(:,5)~=0 & response(:,1)==2),5));

% face specific error rates
% 
% if length(data)<540
%     for face=1:10
%         xxx=size(find(response(:,1)==1 & response(:,7)==-1 & data(:,8)==face),1);
%         yyy=size(find(response(:,1)==1 & response(:,7)==0 & data(:,8)==face),1);
%         face_error_rate(1,face)=xxx;
%         face_error_rate(2,face)=yyy;
%         face_error_rate(3,face)=xxx/(yyy+xxx);
%         xxx=size(find(response(:,1)==2 & response(:,7)==0 & data(:,8)==face),1);
%         yyy=size(find(response(:,1)==2 & response(:,7)==1 & data(:,8)==face),1);
%         face_error_rate(4,face)=xxx;
%         face_error_rate(5,face)=yyy;
%         face_error_rate(6,face)=xxx/(yyy+xxx);       
%     end;
% end;

% vigelence decrement- future...

% dprime and C overall

pHit=1-commission_rate(1,1);
pFA=omission_rate(1,1);
pHit(find(pHit(:)==1))=1-.5/(commission_errors+correct_omission);
pHit(find(pHit(:)==0))=.5/(commission_errors+correct_omission);
pFA(find(pFA(:)==0))=.5/(omission_errors+correct_response);
pFA(find(pFA(:)==1))=1-.5/(omission_errors+correct_response);
HIT=norminv(pHit);
FA=norminv(pFA);
dprime(1,1)=HIT-FA;
criterion(1,1)=(-1*(HIT+FA))/2;

quartile=(length(response)-1)/4;
Q(1,1)=1;
Q(1,2)=round(quartile);
Q(2,1)=(1+round(quartile));
Q(2,2)=round(2*quartile);
Q(3,1)=round(2*quartile+1);
Q(3,2)=round(3*quartile);
Q(4,1)=(round(3*quartile)+1);
Q(4,2)=(length(response)-1);


for q=1:4   %compute each of these for each quartile
    
    response_temp=response(Q(q,1):Q(q,2),:);
    
    %commissions
    
    commission_errors(1,q+1)=size(find(response_temp(:,1)==1 & response_temp(:,7)==-1),1);
    correct_omission(1,q+1)=size(find(response_temp(:,1)==1 & response_temp(:,7)==0),1);
    commission_rate(1,q+1)=commission_errors(1,q+1)/(correct_omission(1,q+1)+commission_errors(1,q+1));
    
    
    %omissions
    
    omission_errors(1,q+1)=size(find(response_temp(:,1)==2 & response_temp(:,7)==0),1);
    correct_response(1,q+1)=size(find(response_temp(:,1)==2 & response_temp(:,7)==1),1);
    omission_rate(1,q+1)=omission_errors(1,q+1)/(correct_response(1,q+1)+omission_errors(1,q+1));
    
    %errors
    
    error_rate(1,q+1)=(omission_errors(1,q+1)+commission_errors(1,q+1))/(correct_response(1,q+1)+omission_errors(1,q+1)+commission_errors(1,q+1)+correct_omission(1,q+1));
    
    %RT of correct responses
    
    meanRT(1,q+1)=mean(response_temp(find(response_temp(:,5)~=0 & response_temp(:,1)==2),5));
    
    %STD of correct responses
    
    STD_RT(1,q+1)=std(response_temp(find(response_temp(:,5)~=0 & response_temp(:,1)==2),5));
    
    % d prime and C quartiles
  
    pHit=1-commission_rate(1,q+1);
pFA=omission_rate(1,q+1);
pHit(find(pHit(:)==1))=1-.5/(commission_errors(1,q+1)+correct_omission(1,q+1));
pHit(find(pHit(:)==0))=.5/(commission_errors(1,q+1)+correct_omission(1,q+1));
pFA(find(pFA(:)==0))=.5/(omission_errors(1,q+1)+correct_response(1,q+1));
pFA(find(pFA(:)==1))=1-.5/(omission_errors(1,q+1)+correct_response(1,q+1));
HIT=norminv(pHit);
FA=norminv(pFA);
dprime(1,q+1)=HIT-FA;
criterion(1,q+1)=(-1*(HIT+FA))/2;
    
end;

% pre RTs

pre_Com=[];
pre_Omi=[];
post_Omi=[];
pre_Cor=[];
post_Com=[];
post_Cor=[];
pre_CO=[];
post_CO=[];

for t=1:(length(response)-1)
    
    if response(t,1)==1 & response(t,7)==-1 & t~=1  %if commission error
        if response(t-1,1)==2 & response(t-1,7)==1    %if previous trial was correct response
            pre_Com=[pre_Com; response(t-1,5)];
        end;
        if response(t+1,1)==2 & response(t+1,7)==1  %if subsequent trial was correct response
            post_Com=[post_Com response(t+1,5)];
        end;
                
    end;
    
    if response(t,1)==2 & response(t,7)==0 & t~=1  %if omission error
        if response(t-1,1)==2 & response(t-1,7)==1    %if previous trial was correct response
            pre_Omi=[pre_Omi; response(t-1,5)];
        end;
    if response(t+1,1)==2 & response(t+1,7)==1 %if subsequent trial was correct response
        post_Omi=[post_Omi response(t+1,5)];
    end;
  end;   
    
    
    if response(t,1)==2 & response(t,7)==1 & t~=1  %if correct response
        if response(t-1,1)==2 & response(t-1,7)==1    %if previous trial was correct response
            pre_Cor=[pre_Cor; response(t-1,5)];
        end;
        if response(t+1,1)==2 & response(t+1,7)==1  %if subsequent trial was correct response
            post_Cor=[post_Cor response(t+1,5)];
        end;
    end;
    
    if response(t,1)==1 & response(t,7)==0 & t~=1 %if correct response
        if response(t-1,1)==2 & response(t-1,7)==1   %if previous trial was correct response
            pre_CO=[pre_CO; response(t-1,5)];
        end;
        if response(t+1,1)==2 & response(t+1,7)==1 %if subsequent trial was correct response
           post_CO=[post_CO response(t+1,5)];
        end;
        
    
end;
end;

%calculations
Pre_RTs=[mean(pre_Com) mean(pre_Omi) mean(pre_Cor) mean(pre_CO)];

Post_RTs=[mean(post_Com) mean(post_Omi) mean(post_Cor) mean(post_CO)];

CV=STD_RT./meanRT;

PES=Post_RTs(1)-Pre_RTs(1);

avg_trial_length=(ttt(size(ttt,1),1)-ttt(1,1))/(size(ttt,1)-1);

%slopes per minute

CE_S=polyfit(1:1:4,commission_rate(2:5),1);
CE_Slope=CE_S(1)/((avg_trial_length)*60);

OE_S=polyfit(1:1:4,omission_rate(2:5),1);
OE_Slope=OE_S(1)/((avg_trial_length)*60);

RT_S=polyfit(1:1:4,meanRT(2:5),1);
RT_Slope=RT_S(1)/((avg_trial_length)*60);

STD_S=polyfit(1:1:4,STD_RT(2:5),1);
STD_Slope=STD_S(1)/((avg_trial_length)*60);

Err_S=polyfit(1:1:4,error_rate(2:5),1);
Err_Slope=Err_S(1)/((avg_trial_length)*60);

dprime_S=polyfit(1:1:4,dprime(2:5),1);
dprime_Slope=dprime_S(1)/((avg_trial_length)*60);

criterion_S=polyfit(1:1:4,criterion(2:5),1);
criterion_Slope=criterion_S(1)/((avg_trial_length)*60);

CV_S=polyfit(1:1:4,CV(2:5),1);
CV_Slope=CV_S(1)/((avg_trial_length))*60;

% if length(data)<540
%     Output=[Pre_RTs Post_RTs commission_rate omission_rate meanRT STD_RT face_error_rate(6,:)];
% else
    Output=[Pre_RTs Post_RTs commission_rate omission_rate meanRT STD_RT error_rate dprime criterion CV PES CE_Slope OE_Slope RT_Slope STD_Slope Err_Slope dprime_Slope criterion_Slope CV_Slope];
% end;


% Memory task

%size(find(list(:,1)==1 & list(:,4)==1),1)-size(find(list(:,1)==2 & list(:,4)==0),1)

        




