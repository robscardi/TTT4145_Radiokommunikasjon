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

function ErrorInput = IntroduceRandomError(InputVectorSection)
        %For testing
        %introduce error
        amountOfError=randi([1 3],1,1);
        ErrorInput=InputVectorSection;
        for q=1:amountOfError
        number=randi([1 24],1,1);
        ErrorInput(number)=~InputVectorSection(number);
        end
end

%%
%Encoding
NOF=4;

P = hex2poly('0xC75');
[H,G] = cyclgen(23, P);
 
G_P = G(1:12, 1:11);
I_K = eye(12);
G = [I_K G_P P.'];
H = [transpose([G_P P.']) I_K];

%LSF Data
DST = ["75","72","20","6D","6F","6D"];
SRC = ["6D","79","44","49","43","4B"];
TYPE = ["00","04"];
META = ["52","61","64","69","6F","6B","6F","6D","6D","75","6E","69","6B", ...
        "61"];
CRC = ["73","6A"];

LSF = [DST,SRC,TYPE,META,CRC];
LSF = hexToArray(LSF,1);


StartValues=[1,41,81,121,161,201];
GolayParts=[1,13,25,37];
OutputParts=[1,25,49,73];

TestOutput=zeros(NOF,48);
EncodedOutput=zeros(NOF,96);

for d=1:NOF
    i=mod(d-1,6)+1;
    start=StartValues(i);
    Chunk=LSF(start:start+40-1);
    TestOutput(d,:) = [Chunk,decToArray(i,1,8)];
    for j=1:4
        section=GolayParts(j);
        m=TestOutput(d,section:section+12-1);
        v=mod(m*G,2);
        section=OutputParts(j);
        EncodedOutput(d,section:section+24-1) = v;
    end
end
%%
%Create lookup table
% Tables because less real time processing --> Money
% See Fredrik Chat log

LUT = containers.Map();

for i = 1:24
    e = zeros(1,24);
    e(i)=1;
    s=mod(H*e',2);
    LUT(num2str(s')) = e;
end

for i = 1:23
    for j = i+1:24
        e=zeros(1,24);
        e(i) = 1;e(j) = 1;
        s = mod(H * e',2);
        LUT(num2str(s')) = e;
    end
end

for i = 1:22
    for j = i+1:23
        for k = j+1:24
            e = zeros(1, 24);
            e(i) = 1; e(j) = 1; e(k) = 1;
            s = mod(H * e', 2);
            LUT(num2str(s')) = e;
        end
    end
end





%%
%Decoding 

InputParts=[1,25,49,73];
InputVector=EncodedOutput;
RecivedVector = zeros(NOF,96);
Errorvector=zeros(4,NOF);
%Receive a single 96 bit codeword
for n=1:NOF
    for j=1:4
        section=InputParts(j);
        InputVectorSection = InputVector(n,section:section+24-1);
        InputVectorSection = IntroduceRandomError(InputVectorSection);
        s=mod(H*InputVectorSection',2);
        if s(1:12)==0
        disp("No errors")
        else
        if isKey(LUT,num2str(s'))
        error_pattern = LUT(num2str(s'));
        c_corrected = xor(InputVectorSection,error_pattern);
        disp("Error Corrected")
        else
            c_corrected = InputVectorSection;
            disp("Error Detected")
        end
        RecivedVector(n,section:section+24-1)=c_corrected;
        end
    end
end

isequal(InputVector,RecivedVector);








