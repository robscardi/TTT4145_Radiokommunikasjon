function Messages = FormatMessageForWorkspace(NOF,ChunkLength,...
    FrameNumberSize, InputData)
    t=zeros(NOF,1);

    Frame_number = zeros(NOF,FrameNumberSize);

    Messages=zeros(NOF,ChunkLength);

    for i=1:NOF
        for j=1:ChunkLength
        Messages(i,j)=InputData(j);
        end
    end 

    if FrameNumberSize==15
        j=1;
        for i=1:NOF
            if i>=2^(FrameNumberSize)-1
                j=1;
            elseif i==NOF
                Frame_number(i,1:16)=decToArray(2^FrameNumberSize,0,16);
            
            else
                Frame_number(i,1:16)=decToArray(j,0,16);
            end
            j=j+1;
        end
    end    

    if FrameNumberSize==5
        j=1;
        for i=1:NOF
            if i>=2^FrameNumberSize
                j=1;
            elseif i==NOF
                Frame_number(i,1:6)=decToArray(57,0,6);
                break
            
            else
                Frame_number(i,1:6)=decToArray(j,0,6);
            end
            j=j+1;
        end
    end
Messages=[t,Messages,Frame_number];
end 