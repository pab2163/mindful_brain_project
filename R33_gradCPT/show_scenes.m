%show scenes

clear all;

y_size=300; %columns/width
x_size=300;  %rows/height

Screen_no=0;

norm=1;

luminance=100;


face_cats={'female' 'male'}; 

scene_cats={'mountain' 'city'};

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

picture_names={scenes_cat1 scenes_cat2 faces_cat1 faces_cat2};
picDir_list={picDir_S{1} picDir_S{2} picDir_F{1} picDir_F{2}};


%get a template face for "tunnel shape"

jpeg_face = imread([picDir_F{1} faces_cat1(1,1).name]);
jpeg_face=imresize(jpeg_face,[x_size,y_size]);
[x,y]=size(jpeg_face);
% pad1=ones((256-x)/2,y)*double(jpeg_face(1,1));
% pad2=ones(256,(256-y)/2)*double(jpeg_face(1,1));
% jpeg_face=[pad1;jpeg_face;pad1];
% jpeg_face=[pad2 jpeg_face pad2];


window=Screen(Screen_no,'OpenWindow');

Screen('TextFont',window, 'Geneva');
Screen('TextSize',window, 40);
Screen('TextStyle', window, 0);

for t=2:-1:1
    CenterText2(window,[scene_cats{t} ' scenes'],[0 0 0 ]);
    
    Screen('Flip',window);
    
    WaitSecs(2);
    
    Screen('Flip',window);
    
    WaitSecs(.5);
    
    for p=1:10
        jpeg=imread([picDir_S{t} picture_names{1,t}(p,1).name]);
        jpeg=jpeg(1:256,1:256);
        jpeg=imresize(jpeg,[x_size,y_size]);
        jpeg(find(jpeg_face==jpeg_face(1,1)))=255;
        
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
        
        WaitSecs(1.5);
        
        Screen('Flip',window);
        
        WaitSecs(.5);
    end;
end;

clear mex;
    
      
        