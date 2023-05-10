function show_betty

Screen_no=0;

norm=0;

luminance=100;

s_size=400;

f_size=250;


face_cats={'female1' 'male'}; 

scene_cats={'mountain' 'city'};

rootdir=cd;

picDir_S={[rootdir '/scenes5/' scene_cats{1} '/'] [rootdir '/scenes5/' scene_cats{2} '/']};
scenes_cat1=dir([picDir_S{1} '*.jpg']);
scenes_cat2=dir([picDir_S{2} '*.jpg']);
picDir_SR1=[rootdir '/scenes5/scrambled_mountain/'];
picDir_SR2=[rootdir '/scenes5/scrambled_city/'];
picDir_SF=[rootdir '/faces/scrambled/'];
scenes_scrambled1=dir([picDir_SR1 '*.jpg']);
scenes_scrambled2=dir([picDir_SR2 '*.jpg']);
picDir_F={[rootdir '/faces/' face_cats{1} '/'] [rootdir '/faces/' face_cats{2} '/']};
faces_cat1=dir([picDir_F{1} '*.bmp']);
faces_cat2=dir([picDir_F{2} '*.bmp']);
scrambled_faces=dir([picDir_SF '*.jpg']);

picture_names={scenes_cat1 scenes_cat2 faces_cat1 faces_cat2};
picDir_list={picDir_S{1} picDir_S{2} picDir_F{1} picDir_F{2}};

%get a template face for "tunnel shape"

jpeg_face = imread([picDir_F{1} faces_cat1(1,1).name]);
jpeg_face1=jpeg_face;
jpeg_face1(jpeg_face==jpeg_face(1,1))=0;
[x,y]=size(jpeg_face);
pad1=ones((s_size-x)/2,y)*double(jpeg_face(1,1));
pad2=ones(s_size,(s_size-y)/2)*double(jpeg_face(1,1));
jpeg_face=[pad1;jpeg_face;pad1];
jpeg_face=[pad2 jpeg_face pad2];
jpeg_face=imresize(jpeg_face,[f_size f_size]);
[x,y]=size(jpeg_face);
pad1=ones((s_size-x)/2,y)*double(jpeg_face(1,1));
pad2=ones(s_size,(s_size-y)/2)*double(jpeg_face(1,1));
jpeg_face=[pad1;jpeg_face;pad1];
jpeg_face=[pad2 jpeg_face pad2];
jpeg_face(jpeg_face>180)=jpeg_face(1,1);


window=Screen(Screen_no,'OpenWindow');

Screen('TextFont',window, 'Geneva');
Screen('TextSize',window, 40);
Screen('TextStyle', window, 0);

for t=1
    CenterText2(window,['Betty'],[0 0 0 ]);
    
    Screen('Flip',window);
    
    WaitSecs(2);
    
    Screen('Flip',window);
    
    WaitSecs(.5);
    
    for p=1:1
        jpeg1=imread([picDir_F{t} picture_names{1,t+2}(p,1).name]);
%        jpeg=jpeg(1:256,1:256);
        [x,y]=size(jpeg1);
        pad1=ones((s_size-x)/2,y)*double(jpeg1(1,1));
        pad2=ones(s_size,(s_size-y)/2)*double(jpeg1(1,1));
        jpeg1=[pad1;jpeg1;pad1];
        jpeg1=[pad2 jpeg1 pad2];
        jpeg1=imresize(jpeg1,[f_size f_size]);
        [x,y]=size(jpeg1);
        pad1=ones((s_size-x)/2,y)*double(jpeg1(1,1));
        pad2=ones(s_size,(s_size-y)/2)*double(jpeg1(1,1));
        jpeg1=[pad1;jpeg1;pad1];
        jpeg1=[pad2 jpeg1 pad2];
        jpeg1(jpeg_face==jpeg_face(1,1))=255;
        jpeg=jpeg1;
        
        if norm
            jpeg=double(jpeg);
            jpeg(find(jpeg_face==jpeg_face(1,1)))=255;
            jpeg_mean=mean(jpeg(find(jpeg~=255)));
            jpeg=jpeg*(luminance/jpeg_mean);
            jpeg(find(jpeg_face==jpeg_face(1,1)))=255;
            jpeg=jpeg+(luminance-mean(jpeg(find(jpeg~=255))));
        end;
        
        Screen(window,'PutImage',jpeg);
    
        Screen('Flip',window);
        
        KbWait;
        
        Screen('Flip',window);
        
        WaitSecs(.5);
    end;
end;

clear mex;
    
      
        