function [wPtr rect] = openProbe

%
%Part of the Trust Game experiment. 
%

screenNum=0;
[wPtr,rect]=Screen('OpenWindow',screenNum);
HideCursor;
white=WhiteIndex(wPtr);
Screen('FillRect',wPtr,white);



