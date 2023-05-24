%time_test

% run 30 secs of GOCPT first

True_trial_length=Rate*framesper;

for x=1:(size(ttt,1)-1)
    test(x)=ttt(x+1,1)-ttt(x,1);
end;

error=test-True_trial_length;

avg_err=mean(error)*1000; %in ms

['Average trial error is ' num2str(avg_err) ' milliseconds']