% Written by Aaron Kucyi

% This script displays the thought probe and meta-awareness screens

function [Results]= thought_probe_func3(window)

%Get the timing params of the experiment:
MW_time=12; % Time to display MW question
Meta_time=12; % Time to display meta-awareness question


%Intialize timing, RT and response structs into which you will record data:
MW_response = {};
Meta_response = {};
MW_RT = zeros(1);
Meta_RT = zeros(1);
MW_onset={};
Meta_onset={};
MW_offset={};
Meta_offset={};

%Set DebugLevel to 3, so that you don't get all kinds of messages flashed
%at you each time you start the experiment:
% Screen('Preference', 'VisualDebuglevel', 3);
[width,height]=Screen('WindowSize', 0);
xcenter = width/2;
ycenter = height/2;

%Open display window and set it up:
wPtr=window; %to be compatible with gradCPT


% Initialize the RGB colours
colorsRGB = struct('white',[255 255 255],'red', [238 8 8], 'blue', [13 9 241], 'pink', [247 5 181], 'green', [22 239 11], 'purple',  [ 91 12 165], 'yellow', [247 236 12], 'orange', [249 114 6], 'black', [0 0 0], 'yellow1', [243 239 10], 'blue1',  [12 9 114], 'red1', [151 13 17], 'pink1', [248 11  187], 'red2', [ 245 5 10] , 'green1', [15 110 12] , 'purple1', [91 7 165], 'blue2', [16 8 201], 'blue3',  [27 33 130] ,'yellow2',  [242 246 7] );
% black=BlackIndex(wPtr);


%%%% Display thought probe %%%%
% ------------------------%


Screen('FillRect',wPtr,[255 255 255]); % makes background white
start_time=GetSecs;
 %start loop of trials

% for trial=1:ntrials
    
    x1=0; %starting x position of cursor
    y1=800;
    
    
% display MW probe
waittime=MW_time; 
start_time_MW=GetSecs;
MW_onset=start_time_MW-start_time;
selftime=0;

while GetSecs-start_time_MW < waittime; 

    [keyIsDown, secs, keyCode] = KbCheck;
Screen('TextSize', wPtr, 50);
Screen('TextStyle', wPtr, 1); % bold text
Screen('TextFont',wPtr,'Arial');
Screen('DrawText',wPtr,'To what degree was your focus just on the task',xcenter-525,ycenter-100,colorsRGB.('black'));
Screen('DrawText',wPtr,'or on something else?',xcenter-275,ycenter-50,colorsRGB.('black'));
Screen('TextSize', wPtr, 40);
Screen('DrawText',wPtr,'Only task',xcenter+350,ycenter+80,colorsRGB.('black'));
Screen('DrawText',wPtr,'Only else',xcenter-480,ycenter+80,colorsRGB.('black'));
Screen('TextSize', wPtr, 70);
Screen('DrawText',wPtr,'^',xcenter+x1,ycenter+y1,colorsRGB.('black'));
Screen('DrawLine', wPtr,colorsRGB.('black'),xcenter+420, ycenter+160,xcenter-380,ycenter+160,3)
Screen('DrawLine', wPtr,colorsRGB.('black'),xcenter+420, ycenter+180,xcenter+420,ycenter+140,3)
Screen('DrawLine', wPtr,colorsRGB.('black'),xcenter-380, ycenter+180,xcenter-380,ycenter+140,3)
Screen('DrawLine', wPtr,colorsRGB.('black'),xcenter+20, ycenter+180,xcenter+20,ycenter+140,3)
Screen(wPtr, 'Flip');


if keyIsDown==1
    if keyCode(KbName('2@')) & MW_RT==0; % if it's the first button press
    MW_RT=secs - start_time_MW;
    y1=y1-650;
    WaitSecs(0.01);    
    elseif keyCode(KbName('3#')) & MW_RT==0; % if it's the first button press
    MW_RT=secs - start_time_MW;
    y1=y1-650;
    WaitSecs(0.01);   
    elseif keyCode(KbName('2@')) & x1>-400;
    x1=x1-8;
    WaitSecs(0.01);    
    elseif keyCode(KbName('3#')) & x1<400;
        x1=x1+8;
        WaitSecs(0.01);
    elseif keyCode(KbName('0)')) & y1==150;
        selftime=1;
        end_time_MW=GetSecs;
        MW_offset=end_time_MW-start_time;
        break
    end

end
 
end

if selftime==0; % record end-trial time if not self-paced by subject
            end_time_MW=GetSecs;
        MW_offset=end_time_MW-start_time;
end

% Record MW probe response

if MW_RT==0;
    MW_response=NaN;
else
MW_response=(x1/8)+50;
end

x1=0; y1=800;

% display Meta-awareness probe
waittime=Meta_time; 
start_time_Meta=GetSecs;
Meta_onset=start_time_Meta-start_time;
selftime=0;

while GetSecs-start_time_Meta < waittime; 

    [keyIsDown, secs, keyCode] = KbCheck;
Screen('TextSize', wPtr, 50);
Screen('TextStyle', wPtr, 1); % bold text
Screen('TextFont',wPtr,'Arial');
Screen('DrawText',wPtr,'To what degree were you aware of your focus?',xcenter-525,ycenter-100,colorsRGB.('black'));
Screen('TextSize', wPtr, 40);
Screen('DrawText',wPtr,'Aware',xcenter+350,ycenter+80,colorsRGB.('black'));
Screen('DrawText',wPtr,'Unaware',xcenter-480,ycenter+80,colorsRGB.('black'));
Screen('TextSize', wPtr, 70);
Screen('DrawText',wPtr,'^',xcenter+x1,ycenter+y1,colorsRGB.('black'));
Screen('DrawLine', wPtr,colorsRGB.('black'),xcenter+420, ycenter+160,xcenter-380,ycenter+160,3)
Screen('DrawLine', wPtr,colorsRGB.('black'),xcenter+420, ycenter+180,xcenter+420,ycenter+140,3)
Screen('DrawLine', wPtr,colorsRGB.('black'),xcenter-380, ycenter+180,xcenter-380,ycenter+140,3)
Screen('DrawLine', wPtr,colorsRGB.('black'),xcenter+20, ycenter+180,xcenter+20,ycenter+140,3)
Screen(wPtr, 'Flip');


if keyIsDown==1
    if keyCode(KbName('2@')) & Meta_RT==0; % if it's the first button press
    Meta_RT=secs - start_time_Meta;
    y1=y1-650;
    WaitSecs(0.01);    
    elseif keyCode(KbName('3#')) & Meta_RT==0; % if it's the first button press
    Meta_RT=secs - start_time_Meta;
    y1=y1-650;
    WaitSecs(0.01);   
    elseif keyCode(KbName('2@')) & x1>-400;
    x1=x1-8;
    WaitSecs(0.01);    
    elseif keyCode(KbName('3#')) & x1<400;
        x1=x1+8;
        WaitSecs(0.01);
    elseif keyCode(KbName('0)')) & y1==150;
        selftime=1;
        end_time_Meta=GetSecs;
        Meta_offset=end_time_Meta-start_time;
        break
    end

end
 
end

if selftime==0; % record end-trial time if not self-paced by subject
            end_time_Meta=GetSecs;
        Meta_offset=end_time_Meta-start_time;
end

% Record Meta probe response

if Meta_RT==0;
    Meta_response=NaN;
else
Meta_response=(x1/8)+50;
end

x1=0; y1=800; 


% end

% MWresponse=cell2mat(MW_response)';
% Metaresponse=cell2mat(Meta_response)';
% MWonset=cell2mat(MW_onset)';
% Metaonset=cell2mat(Meta_onset)';
% 
Results=[MW_response,MW_RT,MW_onset,Meta_response,Meta_RT,Meta_onset,MW_offset,Meta_offset];
% 
% % write output
% 
% dlmwrite(myfile,Results,'\t');

% close display window
% Screen('CloseAll');
% ShowCursor;
