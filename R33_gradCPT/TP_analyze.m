%TP_analyze
%analysis summary for each TP trial
%set to Output these variables:
% TPQ1 TPQ2 CE OE RT STD dp C
% specify a window from TP backwards in trial space, default is while TP trial

function [TP_summary_analysis]=TP_analyze(response,ttt,TP_Results,start_trials,end_trials,window)

% Window definition
if nargin<6 %if no window specified
    window=end_trials-start_trials;
else
    window=window*ones(size(start_trials,1),1);
end;

for TP=1:size(start_trials,1)
    response_temp=response((end_trials(TP)-window):end_trials(TP),:);
    ttt_temp=ttt((end_trials(TP)-window):end_trials(TP),:);
    [Output]=CPT_analyze_func2(response_temp,ttt_temp);
    TP_summary_analysis(TP,:)=[TP_Results(TP,[1 4]) Output([9 14 19 24 34 39])];
    % TPQ1 TPQ2 CE OE RT STD dp C
end;
    