
%%Define hex
function hex = hexToArray(x,y)
hex=hexToBinaryVector(x,8);
hex=transpose(hex);
if y==1
hex=double(reshape(hex,1,[]));
else
hex=reshape(hex,1,[]);
end
end

function binary=decToArray(x,y,z)
binary=decimalToBinaryVector(x,z);
binary=transpose(binary);
if y==1
binary=double(reshape(binary,1,[]));
else
binary=reshape(binary,1,[]);
end
end

function symbolvector=binaryToSymbol(x)
symbolvector=zeros(1,(length(x)/2));
j=1;
for i=1:2:length(x)
    sym=binaryVectorToDecimal([x(i),x(i+1)]);
    switch sym
        case 0
            symbolvector(j)=1;
        case 1
            symbolvector(j)=3;
        case 2
            symbolvector(j)=-1;
        case 3
            symbolvector(j)=-3;
    end
    j=j+1;
end
end

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


function GDI = golayInput(d,ChunkArray,G,GolayParts,StartValues,Arrays...
    ,LSF,OutputParts)
    i=mod(d-1,6)+1;
    start=StartValues(i);
    Chunk=LSF(start:start+40-1);
    ChunkArray(d,:) = [Chunk,decToArray(i,1,8)];
    for j=1:4
        section=GolayParts(j);
        m=ChunkArray(d,section:section+12-1);
        v=mod(m*G,2);
        section=OutputParts(j);
        Arrays(section:section+24-1) = v;
    end
    GDI=[0,Arrays];
end
%%
%%Constants
NOF=16;

Message=["48" "45" "4C" "4C" "4F" "57" "4F" "52" "4C" "44" "23" "23" "23" ...
    "23" "23" "23"];
Message = hexToArray(Message,1);


Packet = ["41", "63", "74", "69", "76", "61", "74", "65", "20", ...
            "47", "6F", "62", "6C", "69", "6E", "20", "6D", "6F", ...
            "64", "65", "20", "6E", "6F", "77", "21"];
Packet = hexToArray(Packet,1);

Preample = [
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77"];
Preample = hexToArray(Preample,1);

EoT = [
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D"];
EoT = hexToArray(EoT,1);

RandomizeSequence = [
    "D6", "B5", "E2", "30", "82", "FF", "84", "62", "BA", "4E", ...
    "96", "90", "D8", "98", "DD", "5D", "0C", "C8", "52", "43", ...
    "91", "1D", "F8", "6E", "68", "2F", "35", "DA", "14", "EA", ...
    "CD", "76", "19", "8D", "D5", "80", "D1", "33", "87", "13", ...
    "57", "18", "2D", "29", "78", "C3"];
RandomizeSequence = hexToArray(RandomizeSequence,0);

%Sync Bursts
SBLSF= ["55", "F7"];
SBLSF=hexToArray(SBLSF,1);
SBStream = ["FF", "5D"];
SBStream = hexToArray(SBStream,1);
SBPacket = ["75", "FF"];
SBPacket = hexToArray(SBPacket,1);


%Interleaving Table
InterleavingVector=zeros(367,1);
for i=1:367
    InterleavingVector(i)=mod((45*i+92*i^2),368);
end


%Puncturing vectors
P1=[1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1; ...
    1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1];

P2 = [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0;];

P3 = [1; 1; 1; 1; 1; 1; 1; 0;];


%LSF Data
DST = ["75","72","20","6D","6F","6D"];
SRC = ["6D","79","44","49","43","4B"];
TYPE = ["00","05"];
META = ["52","61","64","69","6F","6B","6F","6D","6D","75","6E","69","6B", ...
        "61"];
CRC = ["73","6A"];

LSF = [DST,SRC,TYPE,META,CRC];
LSF = hexToArray(LSF,1);

%Golay Generating and Parity Check Matrix
P = hex2poly('0xC75');
[H,G] = cyclgen(23, P);
 
G_P = G(1:12, 1:11);
I_K = eye(12);
G = [I_K G_P P.'];
H = [transpose([G_P P.']) I_K];

StartValues=[1,41,81,121,161,201];
GolayParts=[1,13,25,37];
OutputParts=[1,25,49,73];
ChunkArray=zeros(NOF,48); %Not in plutoradio_init
EncodedOutput=zeros(1,96);



%%
%Implement Message and Data Length
Messages=FormatMessageForWorkspace(NOF,128,15,Message);
Packets=FormatMessageForWorkspace(NOF,200,5,Packet);

%%
%Run Layers
%x=input vector


SendableData=zeros(NOF+3,384);

%Preamble
SendableData(1,:)=Preample;

%LSF
LSF_frame=[0,LSF];
if LSF_frame(1,113)==1
    Stream_mode=1;
else 
    Stream_mode=0;%Packet Mode
end
LSF_chain=sim("transmit_LSF");
SendableData(2,:)=LSF_chain.LSF;

if Stream_mode==1
    for d=1:NOF
    DFM=Messages(d,:);
    LSFC = golayInput(d,ChunkArray,G,GolayParts,StartValues, ... 
        EncodedOutput,LSF,OutputParts);
    tx=sim("transmit_stream.slx");
    SendableData(d+2,:)=tx.stream;
    if binaryVectorToDecimal(tx.FrameNumber)==32768
        SendableData(d+3,:)=EoT;
        break
    end
    end

else
    for d=1:NOF
    DFP=Packets(d,:);
    tx=sim("transmit_packet.slx");
    SendableData(d+2,:)=tx.Packet;
    if tx.MetaData(1,1)==1
        SendableData(d+3,:)=EoT;
        break
    end

    end
end


%%
%Upsample Frame by Frame (192 symbols)
%Upsampling Factor
Ufactor=10;
alpha = 0.5;
SymbolSpan = 8;

t=zeros(height(SendableData),1);

SendableDataWithTime=[t,SendableData];

DataToPluto = zeros(height(SendableDataWithTime),width(SendableData)*5);
for d=1:height(SendableDataWithTime)
    DTP=SendableDataWithTime(d,:);
    output=sim("raised_cosine");
    DataToPluto(d,:) = output.filtered;
end













