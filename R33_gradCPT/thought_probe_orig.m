% Written by Aaron Kucyi
% Last update: Dec. 22, 2014

% This script displays the thought probe and meta-awareness screens

clear all; close all;

%Initialize the path:
home = [cd '/'];
addpath(home)

% get subject id
id = input('Enter Subject ID: ')
session = input('Enter Session number: ')
run= input('Enter Run number: ')
% initialize path to output file
a=int2str(id); b='-'; c=int2str(session); d='-'; e=int2str(run); f='-ThoughtProbes'; label=strcat(a,b,c,d,e,f);
myfile = [home 'output' label '.txt'];

%Get the timing params of the experiment:
MW_time=7; % Time to display MW question
Meta_time=7; % Time to display meta-awareness question


% Set number of trials 
ntrials=2;

%Intialize timing, RT and response structs into which you will record data:
MW_response = {};
Meta_response = {};
MW_RT = zeros(ntrials,1);
Meta_RT = zeros(ntrials,1);
MW_onset={};
Meta_onset={};

%Set DebugLevel to 3, so that you don't get all kinds of messages flashed
%at you each time you start the experiment:
Screen('Preference', 'VisualDebuglevel', 3);
[width,height]=Screen('WindowSize', 0);
xcenter = width/2;
ycenter = height/2;

%Open display window and set it up:
[wPtr rect] = openProbe;


% Initialize the RGB colours
colorsRGB = struct('white',[255 255 255],'red', [238 8 8], 'blue', [13 9 241], 'pink', [247 5 181], 'green', [22 239 11], 'purple',  [ 91 12 165], 'yellow', [247 236 12], 'orange', [249 114 6], 'black', [0 0 0], 'yellow1', [243 239 10], 'blue1',  [12 9 114], 'red1', [151 13 17], 'pink1', [248 11  187], 'red2', [ 245 5 10] , 'green1', [15 110 12] , 'purple1', [91 7 165], 'blue2', [16 8 201], 'blue3',  [27 33 130] ,'yellow2',  [242 246 7] );
black=BlackIndex(wPtr);


%%%% Display thought probe %%%%
% ------------------------%


Screen('FillRect',wPtr,black); % makes background black
start_time=GetSecs;
 %start loop of trials

for trial=1:ntrials
    
    x1=0; %starting x position of cursor
    
    
% display MW probe
waittime=MW_time; 
start_time_MW=GetSecs;
MW_onset{trial}=start_time_MW-start_time;


while GetSecs-start_time_MW < waittime; 

    [keyIsDown, secs, keyCode] = KbCheck;
Screen('TextSize', wPtr, 50);
Screen('TextStyle', wPtr, 1); % bold text
Screen('TextFont',wPtr,'Arial');
Screen('DrawText',wPtr,'To what degree was your focus just on the task',xcenter-525,ycenter-100,colorsRGB.('white'));
Screen('DrawText',wPtr,'or on something else?',xcenter-275,ycenter-50,colorsRGB.('white'));
Screen('TextSize', wPtr, 40);
Screen('DrawText',wPtr,'Only task',xcenter+350,ycenter+100,colorsRGB.('white'));
Screen('DrawText',wPtr,'Mostly task',xcenter+100,ycenter+100,colorsRGB.('white'));
Screen('DrawText',wPtr,'Mostly else',xcenter-250,ycenter+100,colorsRGB.('white'));
Screen('DrawText',wPtr,'Only else',xcenter-500,ycenter+100,colorsRGB.('white'));
Screen('TextSize', wPtr, 70);
Screen('DrawText',wPtr,'^',xcenter+x1,ycenter+150,colorsRGB.('white'));

Screen(wPtr, 'Flip');


if keyIsDown==1
    if keyCode(KbName('LeftArrow')) & MW_RT(trial,1)==0; % if it's the first button press
    MW_RT(trial,1)=secs - start_time_MW;
    x1=x1-200;
    WaitSecs(0.06);    
    elseif keyCode(KbName('RightArrow')) & MW_RT(trial,1)==0; % if it's the first button press
    MW_RT(trial,1)=secs - start_time_MW;
    x1=x1+200;
    WaitSecs(0.06);   
    elseif keyCode(KbName('LeftArrow')) & x1>-300;
    x1=x1-200;
    WaitSecs(0.06);    
    elseif keyCode(KbName('RightArrow')) & x1<300;
        x1=x1+200;
        WaitSecs(0.06);     
    end

end

end

% Record MW probe response

if x1==-200; MW_response{trial}=4;
elseif x1==-400; MW_response{trial}=3;
elseif x1==200; MW_response{trial}=2;
    elseif x1==400; MW_response{trial}=1;
    else MW_response{trial}=NaN;
    end
x1=0;

% display Meta-awareness probe
waittime=Meta_time; 
start_time_Meta=GetSecs;
Meta_onset{trial}=start_time_Meta-start_time;


while GetSecs-start_time_Meta < waittime; 

    [keyIsDown, secs, keyCode] = KbCheck;
Screen('TextSize', wPtr, 50);
Screen('TextStyle', wPtr, 1); % bold text
Screen('TextFont',wPtr,'Arial');
Screen('DrawText',wPtr,'To what degree were you aware of your focus?',xcenter-525,ycenter-100,colorsRGB.('white'));
Screen('TextSize', wPtr, 30);
Screen('DrawText',wPtr,'Very aware',xcenter+375,ycenter+100,colorsRGB.('white'));
Screen('DrawText',wPtr,'Somewhat aware',xcenter+100,ycenter+100,colorsRGB.('white'));
Screen('DrawText',wPtr,'Somewhat unaware',xcenter-300,ycenter+100,colorsRGB.('white'));
Screen('DrawText',wPtr,'Very unaware',xcenter-525,ycenter+100,colorsRGB.('white'));
Screen('TextSize', wPtr, 70);
Screen('DrawText',wPtr,'^',xcenter+x1,ycenter+150,colorsRGB.('white'));

Screen(wPtr, 'Flip');


if keyIsDown==1
    if keyCode(KbName('LeftArrow')) & Meta_RT(trial,1)==0; % if it's the first button press
    Meta_RT(trial,1)=secs - start_time_MW;
    x1=x1-200;
    WaitSecs(0.06);    
    elseif keyCode(KbName('RightArrow')) & Meta_RT(trial,1)==0; % if it's the first button press
    Meta_RT(trial,1)=secs - start_time_Meta;
    x1=x1+200;
    WaitSecs(0.06);   
    elseif keyCode(KbName('LeftArrow')) & x1>-300;
    x1=x1-200;
    WaitSecs(0.06);    
    elseif keyCode(KbName('RightArrow')) & x1<300;
        x1=x1+200;
        WaitSecs(0.06);     
    end

end

end

% Record meta-awareness probe response
if x1==-200; Meta_response{trial}=4;
elseif x1==-400; Meta_response{trial}=3;
elseif x1==200; Meta_response{trial}=2;
    elseif x1==400; Meta_response{trial}=1;
    else Meta_response{trial}=NaN;
    end

end

MWresponse=cell2mat(MW_response)';
Metaresponse=cell2mat(Meta_response)';
MWonset=cell2mat(MW_onset)';
Metaonset=cell2mat(Meta_onset)';

Results=[MWresponse,MW_RT,MWonset,Metaresponse,Meta_RT,Metaonset];

% write output

dlmwrite(myfile,Results,'\t');

% close display window
Screen('CloseAll');
ShowCursor;
