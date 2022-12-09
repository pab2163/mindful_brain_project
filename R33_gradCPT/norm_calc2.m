%gives quick z score for CEs and STD for ages 17-70 based on TMB data
%After CPT task ends, simply paste sytax "[zscore]=norm_calc2(sub_age,response)" into command
%window with sub_age as the subject's age (i.e. 20)

function [zscore]=norm_calc2(sub_age,response)

CPT_analyze;

load('TMB_age_norms.mat');

age_bin_sub=0;

for a=1:size(age_bin_list,1)
    if sub_age>=age_bin_list(a,1) & sub_age<=age_bin_list(a,2)
        age_bin_sub=a;
    end;
end;

if age_bin_sub==0;
        ['WARNING: age not in normative range']
end;

try
zscoreCE=(Output(6)-norm_stats(1,age_bin_sub,3))/norm_stats(2,age_bin_sub,3);

zscoreSTD=((1000*Output(21))-norm_stats(1,age_bin_sub,2))/norm_stats(2,age_bin_sub,2);

zscore=[zscoreCE zscoreSTD];
catch
    zscore='NaN';
end;

disp(['Your error rate is ' [num2str(zscoreCE)] ' standard deviations greater than the mean']);
disp(['Your response variability is ' [num2str(zscoreSTD)] ' standard deviations greater than the mean']);