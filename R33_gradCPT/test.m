% Updated for scanning 9/17/10
% updated for resize mse, 9/20/10
% updated for larger resize, 32-channel projector 1/12/12 mse
%new code: lines 21-22  152-155  173-176  191-199  249-252  266-274

clear all; ClockRandSeed;

%%%%%%%%%%%%%%response codes

r1=30; % ' ' for response key 1 (cat2)     male\city

r2=29;  % '.' for response key 2 (cat1)     female\mountain

r1_MRI=21; % red button for response key 1 (cat2)     male\city

r2_MRI=10;  % green button for response key 2 (cat1)     female\mountain

scene_cats={'mountain' 'city'}; %city 2nd

face_cats={'female' 'male'}; 

y_size=300; %columns/width % good for 1024 x 768 res
x_size=300;  %rows/height


%%%%%%%%%%%%%%%%%%%%%%%%%%dialogue box

prompt = {'Enter subject name','Rate','Duration','fMRI','Prac','FHR','Prob','Hold','Scram','Task','framesper'};
def={'XXX','.05','30','0','0','0','.9','.05','0','2','24'};
answer = inputdlg(prompt, 'Experimental setup information',1,def);
[subName, Rate, duration, fMRI, Prac, FHR, Prob, Hold,SR,Task,framesper] = deal(answer{:});

%norm=str2num(norm);
norm=1;
Rate=str2num(Rate);
duration=str2num(duration);
Prac=str2num(Prac);
fMRI=str2num(fMRI);
%luminance=str2num(lum);
luminance=110;
FHR=str2num(FHR);
%Screen_no=str2num(Screen_no);
Screen_no=1;
Prob=str2num(Prob);
HoldTime=str2num(Hold);
%Flip=str2num(Flip);
Flip=0;
Scram=str2num(SR);
Task=str2num(Task); %1=go-nogo face gender %2=go-nogo scene type %3=2AFC face gender %4=2AFC scene type
framesper=str2num(framesper);

if Prob==.9
    Prob=10;
elseif Prob==.5
    Prob=2;
end;%frequency of city/mountain parameter transform

facey=FHR;
housey=1-FHR;

%framesper=25;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get all the picture dirs and names

rootdir=cd;

picDir_S={[rootdir '/scenes5/' scene_cats{1} '/'] [rootdir '/scenes5/' scene_cats{2} '/']};
scenes_cat1=dir([picDir_S{1} '*.jpg']);
scenes_cat2=dir([picDir_S{2} '*.jpg']);
picDir_SR=[rootdir '/scenes5/scrambled/'];
picDir_SF=[rootdir '/faces/scrambled/'];
scenes_scrambled=dir([picDir_SR '*.jpg']);
picDir_F={[rootdir '/faces/' face_cats{1} '/'] [rootdir '/faces/' face_cats{2} '/']};
faces_cat1=dir([picDir_F{1} '*.bmp']);
faces_cat2=dir([picDir_F{2} '*.bmp']);
scrambled_faces=dir([picDir_SF '*.jpg']);

if Scram==1     %sramble scene
    picture_names={scenes_scrambled scenes_scrambled faces_cat1 faces_cat2};   
    picDir_list={picDir_SR picDir_SR picDir_F{1} picDir_F{2}};

elseif Scram==2  %sramble face
    picture_names={scenes_cat1 scenes_cat2 scrambled_faces scrambled_faces};   
    picDir_list={picDir_S{1} picDir_S{2} picDir_SF picDir_SF};

else
    picture_names={scenes_cat1 scenes_cat2 faces_cat1 faces_cat2};
    picDir_list={picDir_S{1} picDir_S{2} picDir_F{1} picDir_F{2}};

end;


image_sum=[0 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%% buttons and trigger

if fMRI
    [KB_id] = FORPInit();
    [trigger_id] = TriggerInit();
else
    %[KB_id] = FORPInit(); %just for testing
    [KB_id]=KBInit;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%% screen and timing preparation

window=Screen(Screen_no,'OpenWindow');

HideCursor;

%screen refresh

hz = FrameRate(window);

refresh=1/hz;

Rate=round(Rate/refresh)*refresh;

HoldTime=round(HoldTime/refresh)*refresh;

numberoftrials=round(duration/(Rate*(framesper-1)+HoldTime));

duration=numberoftrials*(Rate*(framesper-1)+HoldTime);

WaitTime=Rate;


% if fMRI==1
%     Screen('TextFont',window, 'Geneva');
%     Screen('TextSize',window, 30);
%     Screen('TextStyle', window, 1+2);
%     CenterText2(window,['Get Ready']);
%     Screen('Flip',window);
%     clearserialbytes(1);
%     P=999;
%     while 1,
%         P=waitserialbyte(1,inf);
%         if sum(P(1)==serial_sync)>0;
%             sync=1;
%             SyncLog(sync,1)=GetSecs;
%             sync=sync+1;
%             Screen('Flip',window);
%             break;
%         end
%     end;
% end;

%get a template face for "tunnel shape"

jpeg_face = imread([picDir_F{1} faces_cat1(1,1).name]);
[x,y]=size(jpeg_face);
%to resize jpeg_face%%%%%%
jpeg_face=imresize(jpeg_face,[x_size,y_size]);
[x,y]=size(jpeg_face);
%%%%%%%%%%%%%%%%%%%%%%%%%%
% pad1=ones((256-x)/2,y)*double(jpeg_face(1,1));
% pad2=ones(256,(256-y)/2)*double(jpeg_face(1,1));
% jpeg_face=[pad1;jpeg_face;pad1];
% jpeg_face=[pad2 jpeg_face pad2];

%%%%%%make random trial list


%pick a random face and scene- T1
face_type=randi(Prob);  if face_type>2  face_type=2; end;
face_r=randi(size(picture_names{face_type+2},1));
scene_type=randi(Prob); if scene_type>2  scene_type=2; end;
scene_r=randi(size(picture_names{scene_type},1));

%T1 face (noise for n=1)
jpeg1 = imread([picDir_SF 'SF' num2str(randi(10)) '.jpg']);
[x,y]=size(jpeg1);
%to resize jpeg1%%%%
jpeg1=imresize(jpeg1,[x_size,y_size]);
[x,y]=size(jpeg1);
%%%%%%%%%%%%%%%%%%%%
% pad1=ones((256-x)/2,y)*double(jpeg1(1,1));
% pad2=ones(256,(256-y)/2)*double(jpeg1(1,1));
% jpeg1=[pad1;jpeg1;pad1];
% jpeg1=[pad2 jpeg1 pad2];
face_type=0; face_r=0;
if Flip==2  %flip face
    jpeg1=flipud(jpeg1);
end;


%T1 scene (noise for n=1)

jpeg2 = imread([picDir_SR 'SS' num2str(randi(10)) '.jpg']); %start with random scene
jpeg2=jpeg2(1:256,1:256); %jpeg_ends=jpeg2;
%to resize jpeg2%%%%%%%%%
[x,y]=size(jpeg2);
jpeg2=imresize(jpeg2,[x_size,y_size]);
[x,y]=size(jpeg2);
% pad1=ones((256-x)/2,y)*double(jpeg2(1,1));
% pad2=ones(256,(256-y)/2)*double(jpeg2(1,1));
% jpeg2=[pad1;jpeg2;pad1];
% jpeg2=[pad2 jpeg2 pad2];
%%%%%%%%%%%%%%%%%%%%%%%%%%

scene_type=0; scene_r=0;
if Flip==1  %flip scene
    jpeg2=flipud(jpeg2);
end;

%average the face and scene- at first, just scramble-
jpeg_M1=double(jpeg1)*facey+double(jpeg2)*housey;
jpeg_M1(find(jpeg_face==jpeg_face(1,1)))=255;
jpeg_ends=jpeg_M1;

if norm
    M1_mean=mean(jpeg_M1(find(jpeg_M1~=255)));
    jpeg_M1=jpeg_M1*(luminance/M1_mean);
    jpeg_M1(find(jpeg_face==jpeg_face(1,1)))=255;
    jpeg_M1=jpeg_M1+(luminance-mean(jpeg_M1(find(jpeg_M1~=255))));
end;

Screen('TextFont',window, 'Geneva');
Screen('TextSize',window, 20);
Screen('TextStyle', window, 0);

for n=1:numberoftrials
    

%     
%     CenterText2(window,['actual rate: ' num2str(Rate)],[0 0 0],0, 100);
%     CenterText2(window,['actual duration: ' num2str(duration)],[0 0 0],0, 200);
    
    CenterText2(window,['Loading: ' num2str(round((n/numberoftrials*100))) '% completed'],[0 0 0],0, 0);
    
    Screen('Flip',window);
    
    %list.jpeg{n,1}=jpeg_M1;
    % pick a random face and scene- T2 and don't let it be the same one as last
    % trial
    face_type_r2=randi(Prob); if face_type_r2>2  face_type_r2=2; end;
    face_r2=randi(size(picture_names{face_type_r2+2},1));
    while face_r==face_r2 & face_type==face_type_r2
        face_r2=randi(size(picture_names{face_type_r2+2},1));
    end;
    scene_type_r2=randi(Prob); if scene_type_r2>2  scene_type_r2=2; end;
    scene_r2=randi(size(picture_names{scene_type_r2},1));
    while scene_r==scene_r2 & scene_type==scene_type_r2
        scene_r2=randi(size(picture_names{scene_type_r2},1));
    end;
    
    jpeg3 = imread([picDir_list{face_type_r2+2} picture_names{1,face_type_r2+2}(face_r2,1).name]);
    [x,y]=size(jpeg3);
    %to resize jpeg3%%%%
    jpeg3=imresize(jpeg3,[x_size,y_size]);
    [x,y]=size(jpeg3);
    %%%%%%%%%%%%%%%%%%%%
%     pad1=ones((256-x)/2,y)*double(jpeg3(1,1));
%     pad2=ones(256,(256-y)/2)*double(jpeg3(1,1));
%     jpeg3=[pad1;jpeg3;pad1];
%     jpeg3=[pad2 jpeg3 pad2];
    if Flip==2 %flip face
        jpeg3=flipud(jpeg3);
    end;
    
    jpeg4 = imread([picDir_list{scene_type_r2} picture_names{1,scene_type_r2}(scene_r2,1).name]);
%     if n==numberoftrials
%         jpeg4=jpeg_ends;
%     end;
    jpeg4=jpeg4(1:256,1:256);
    %to resize jpeg4%%%%%%%%%
    [x,y]=size(jpeg4);
    jpeg4=imresize(jpeg4,[x_size,y_size]);
    [x,y]=size(jpeg4);
%     pad1=ones((256-x)/2,y)*double(jpeg4(1,1));
%     pad2=ones(256,(256-y)/2)*double(jpeg4(1,1));
%     jpeg4=[pad1;jpeg4;pad1];
%     jpeg4=[pad2 jpeg4 pad2];
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    if Flip==1 %flip scene
        jpeg4=flipud(jpeg4);
    end;
    if norm
        jpeg4=double(jpeg4);
        jpeg4(find(jpeg_face==jpeg_face(1,1)))=255;
        jpeg4_mean=mean(jpeg4(find(jpeg4~=255)));
        jpeg4=jpeg4*(luminance/jpeg4_mean);
        jpeg4(find(jpeg_face==jpeg_face(1,1)))=255;
        jpeg4=jpeg4+(luminance-mean(jpeg4(find(jpeg4~=255))));
    end;
    
    
    data(n,1)=scene_type; data(n,2)=scene_r;  data(n,3)=scene_type_r2; data(n,4)=scene_r2;
    data(n,5)=face_type; data(n,6)=face_r; data(n,7)=face_type_r2; data(n,8)=face_r2;
    
    % average face and scene
    jpeg_M2=double(jpeg3)*facey+double(jpeg4)*housey;
    jpeg_M2(find(jpeg_face==jpeg_face(1,1)))=255;
    if n==numberoftrials
        jpeg_M2=jpeg_ends; data(n,3:4)=0; data(n,7:8)=0;
    end;
%     if norm
%         M2_mean=mean(jpeg_M2(find(jpeg_M2~=255)));
%         jpeg_M2=jpeg_M2*(luminance/M2_mean);
%         jpeg_M2(find(jpeg_face==jpeg_face(1,1)))=255;
%         jpeg_M2=jpeg_M2+(luminance-mean(jpeg_M2(find(jpeg_M2~=255))));
%     end;
    
    diff=double(jpeg_M2)-double(jpeg_M1); 
    
%     for j=1:25
%         jpeg=(jpeg_M1+(diff/25)*(j-1));
%         jpeg(find(jpeg_face==jpeg_face(1,1)))=255;
%         list.jpeg{n,j}=jpeg;
%     end;

    list.jpeg{n,1}=jpeg_M1;
    list.jpeg{n,2}=jpeg_M2;
    list.jpeg{n,3}=diff;
    list.jpeg{n,4}=mean(mean(abs(diff)));

    %make the T2 the T1
    jpeg_M1=jpeg_M2;
    face_type=face_type_r2;
    face_r=face_r2;
    scene_r=scene_r2;
    scene_type=scene_type_r2;
    
end;

list.pics=data(:,1:8);

%diff=double(jpeg_M2)-double(jpeg_M1);  %diff between trial n and n+1

  data(numberoftrials,10)=0;
% % 
 %jpeg=(jpeg_M1);
% 
 ttt=zeros(numberoftrials,framesper);
% 
res_trial=0;

keyIsDown=0;

StimulusOnsetTime=GetSecs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%Get Ready Screens

% Screen('TextFont',window, 'Geneva');
% Screen('TextSize',window, 40);
% Screen('TextStyle', window, 0);
% 
% CenterText2(window,['actual rate: ' num2str(Rate)],[0 0 0],0, 100);7
% CenterText2(window,['actual duration: ' num2str(duration)],[0 0 0],0, 0);

% Screen('Flip',window);
% 
% KbWait;

% Screen('Flip',window);
% 
% WaitSecs(.5);

Screen('TextSize',window, 40);

FlushEvents('KeyDown'); 

if fMRI==1
        CenterText2(window,['Get Ready'],[0 0 0 ],0,300);
        KeyPressed='';
        
elseif fMRI==0
        CenterText2(window,['Get Ready'],[0 0 0],0, 300);
end;


Screen(window,'PutImage',list.jpeg{1,1});
    
Screen('Flip',window);
    
if fMRI==0
    KbWait2(KB_id);
%            while KbCheck; end % Wait until all keys released
%                     gotTrig = 0;
%                     %writeLog(lf, 'waiting for trigger...\n');
%                     while ~gotTrig
%                         [~, ~, keyCode] = KbCheck;
%                         textStr = KbName(keyCode);
%                         if iscell(textStr)
%                             textStr = [textStr{:}];
%                         end
%                         %if (keyCode(trigKey) || keyCode(returnKey))
%                         if ~isempty(strfind(textStr, '=+')) 
% %                            ~isempty(strfind(textStr, 'space'))
%                         %if (strcmp(textStr, '=+') || strcmp(textStr, 'return'))
%                             gotTrig = 1;
%                         end
%                     end
RestrictKeysForKbCheck([30, 31, 32, 33, 39]); % added    
%     KbWait(KB_id);
elseif fMRI==1
    KbWait2(trigger_id);
end;

Screen(window,'PutImage',list.jpeg{1,1}); 

Screen('Flip',window); 

starttime=GetSecs;

%WaitSecs(3-Rate*25);%-.100);

if fMRI
    WaitSecs(8);
end;


%%%%%%%%%%%%%%%%BEGIN TRIAL LOOP

% if fMRI
%     FORPQueueClear(psychtoolbox_trigger_id);
%     %FORPQueueClear(psychtoolbox_forp_id);
% end;


for n=1:numberoftrials
    
    res_count=0; last_resp_frame=0;
    
    for j=1:framesper
        %t2=GetSecs;
        res_trial=0;
        jpeg=(list.jpeg{n,1}+(list.jpeg{n,3}/framesper)*(j-1));
        jpeg(find(jpeg_face==jpeg_face(1,1)))=255;
        Screen(window,'PutImage',jpeg);

        [VBLTimestamp StimulusOnsetTime]=Screen('Flip',window,StimulusOnsetTime+WaitTime-.010);
        
        ttt(n,j)=StimulusOnsetTime;
        
        if j==1 data(n,9)=StimulusOnsetTime; %WaitSecs(.800-Rate); 
        end;
        
        if j==framesper WaitTime=HoldTime; else WaitTime=Rate; end;
        
%         if fMRI==0 %& j<25
            while GetSecs-StimulusOnsetTime<(WaitTime-.030),
                keyIsDown=0;
                FlushEvents('KeyDown');
    
                [keyIsDown, secs, keyCode] = KbCheck; %removed KbCheck(kb_id) for fMRI
                if keyIsDown==1 & res_trial==0 & (j-last_resp_frame>5 | last_resp_frame==0);
                    data(n,10+res_count*3)=sum(find(keyCode));
                    data(n,11+res_count*3)=secs;
                    data(n,12+res_count*3)=j;
                    last_resp_frame=j;
                    keyIsDown=0;
                    FlushEvents('KeyDown');
                    res_trial=1;
                    res_count=res_count+1;
                end
            end
            if data(n,10)==36        %Bail out if they press '7'
                %                 clear mex;
                %                 stopit;
                clear mex;
                stopitnow;
                ShowCursor;
            end;
            if data(n,10)==19 %pause is 'p'
                FlushEvents;
                WaitSecs(.5);
                KbWait(KB_id);
                FlushEvents;
            end;
%          elseif fMRI==1
%              while GetSecs-StimulusOnsetTime<(WaitTime-.030),
%                  keyIsDown=0;
%                  [KeyPressed,EventTime] = FORPWait2((Rate-.020),psychtoolbox_trigger_id);
%                  if KeyPressed==['1'] | KeyPressed==['2'] | KeyPressed==['3'] | KeyPressed==['4']
%                      keyIsDown=1;
%                  end;
%                  if keyIsDown==1 & res_trial==0 & (j-last_resp_frame>5 | last_resp_frame==0);
%                      data(n,10+res_count*3)=str2num(KeyPressed);
%                      data(n,11+res_count*3)=EventTime;
%                      data(n,12+res_count*3)=j;
%                      last_resp_frame=j;
%                      keyIsDown=0;
%                      FlushEvents('KeyDown');
%                      res_trial=1;
%                      res_count=res_count+1;
%                  end;
%              end
%         end;
        %if j==30 WaitSecs(.150); end;
%         while GetSecs-t2<Rate
%         end;
    end;
    
    
end;

if fMRI
    WaitSecs(8);
end;

Screen('Flip',window);
endtime=GetSecs;
ShowCursor;

%%%%%%%%%%%%%%%%analyze and save data

if fMRI
    [response]=get_RTs5(data,numberoftrials,r1_MRI,r2_MRI,framesper,Task);
else
    [response]=get_RTs5(data,numberoftrials,r1,r2,framesper,Task);
end;

clear mex;
C=clock;
mkdir data;
cd data
'saving data- wait!'
save(['Data_' num2str(Prac) '_' subName '_' date '_' num2str(C(4)) '_' num2str(C(5)) '_city_mnt_v1B_beh_fMRI.mat'],'data', 'response','ttt','FHR','Rate','Prob','Task','Scram', 'framesper', 'numberoftrials', 'subName','starttime','endtime','x_size','y_size');
cd ..
WaitSecs(1);

%Kbwait;
Screen('CloseAll');