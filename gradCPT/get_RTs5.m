%this should work with any framesper value, for go-nogo

function [response]=get_RTs5(data,numberoftrials,r1,r2,framesper,Task);

response=zeros(numberoftrials,7);
if rem(Task,2)      %Task is 1 or 3, so face
    response(:,1)=data(1:numberoftrials,7);
else                 %Task is 2 or 4, so scene
    response(:,1)=data(1:numberoftrials,3);
end;

for n=1:numberoftrials
    for r=1:(size(data,2)-9)/3
        if data(n,12+3*(r-1))>.8*framesper & response(n,4)==0  %if >70% coming on, RT = current trial
            response(n,2)=data(n,10+3*(r-1));
            response(n,3)=data(n,11+3*(r-1));
            response(n,4)=data(n,12+3*(r-1))*(100/framesper);
            response(n,5)=data(n,11+3*(r-1))-data(n,9);
            response(n,6)=1;
        end;
        if data(n,12+3*(r-1))<.4*framesper & data(n,12+3*(r-1))>0 & n~=1   %if <40% coming on, RT = previous trial
            if response(n-1,2)==0
                response(n-1,2)=data(n,10+3*(r-1));
                response(n-1,3)=data(n,11+3*(r-1));
                response(n-1,4)=100-data(n,12+3*(r-1))*(100/framesper);
                response(n-1,5)=data(n,11+3*(r-1))-data(n-1,9);
                response(n-1,6)=2;
            end;
        end;
    end;
end;

for n=1:numberoftrials
    for r=1:(size(data,2)-9)/3
        if data(n,12+3*(r-1))<=.8*framesper & data(n,12+3*(r-1))>=.4*framesper & response(n,4)~=0 & n~=1  
            %if btw 40-70% coming on, RT = previous trial if current trial
            %already has an RT and previous doesnt
            if response(n-1,4)==0
                response(n-1,2)=data(n,10+3*(r-1));
                response(n-1,3)=data(n,11+3*(r-1));
                response(n-1,4)=100-data(n,12+3*(r-1))*(100/framesper);
                response(n-1,5)=data(n,11+3*(r-1))-data(n-1,9);
                response(n-1,6)=2;
            end;
 
        elseif data(n,12+3*(r-1))<=.8*framesper & data(n,12+3*(r-1))>=.4*framesper & response(n,4)==0 & n~=1
            %if btw 40-70% coming on, RT = current trial if previous trial
            %already has an RT and current doesn't
            if response(n-1,4)~=0
                response(n,2)=data(n,10+3*(r-1));
                response(n,3)=data(n,11+3*(r-1));
                response(n,4)=data(n,12+3*(r-1))*(100/framesper);
                response(n,5)=data(n,11+3*(r-1))-data(n,9);
                response(n,6)=1;
            end;
        end;
        if data(n,12+3*(r-1))<=.8*framesper & data(n,12+3*(r-1))>=.4*framesper & response(n,4)==0 & n~=1
            %if btw 40-70% coming on, and no response on n or n-1, split
            %the difference
            
            if response(n,1)==1 & response(n-1,1)~=1%unless current is catch trial
                    response(n-1,2)=data(n,10+3*(r-1));
                    response(n-1,3)=data(n,11+3*(r-1));
                    response(n-1,4)=100-data(n,12+3*(r-1))*(100/framesper);
                    response(n-1,5)=data(n,11+3*(r-1))-data(n-1,9);
                    response(n-1,6)=2;
            elseif response(n,1)~=1 & response(n-1,1)==1%unless previous is catch trial
                    response(n,2)=data(n,10+3*(r-1));
                    response(n,3)=data(n,11+3*(r-1));
                    response(n,4)=data(n,12+3*(r-1))*(100/framesper);
                    response(n,5)=data(n,11+3*(r-1))-data(n,9);
                    response(n,6)=1;
            elseif response(n-1,4)==0
                if data(n,12+3*(r-1))>.6*framesper
                    response(n,2)=data(n,10+3*(r-1));
                    response(n,3)=data(n,11+3*(r-1));
                    response(n,4)=data(n,12+3*(r-1))*(100/framesper);
                    response(n,5)=data(n,11+3*(r-1))-data(n,9);
                    response(n,6)=1;
                elseif data(n,12+3*(r-1))<=.6*framesper
                    response(n-1,2)=data(n,10+3*(r-1));
                    response(n-1,3)=data(n,11+3*(r-1));
                    response(n-1,4)=100-data(n,12+3*(r-1))*(100/framesper);
                    response(n-1,5)=data(n,11+3*(r-1))-data(n-1,9);
                    response(n-1,6)=2;
                end;
            end;
        end;
        if data(n,12+3*(r-1))<=.8*framesper & data(n,12+3*(r-1))>=.4*framesper & response(n,4)==0 & n==1
            response(n,2)=data(n,10+3*(r-1));
            response(n,3)=data(n,11+3*(r-1));
            response(n,4)=data(n,12+3*(r-1))*(100/framesper);
            response(n,5)=data(n,11+3*(r-1))-data(n,9);
            response(n,6)=1;
        end;
    end;
end;

for n=1:numberoftrials
    if (response(n,1)==2 & response(n,2)==r1) | (response(n,1)==1 & response(n,2)==r2)
        response(n,7)=1;
    elseif (response(n,1)==2 & response(n,2)==r2) | (response(n,1)==1 & response(n,2)==r1)
        response(n,7)=-1;
    end;
end;