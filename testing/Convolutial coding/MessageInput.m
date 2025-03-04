Message=[72 69 76 76 79 87 79 82 76 68 35 35 35 35 35 35]
BinaryMessage=decimalToBinaryVector(Message,8)
BinaryMessage=transpose(BinaryMessage)
BinaryMessage=reshape(BinaryMessage,1,[])

Frame_number=32767;


for c=1:10
y = bitget(c,1:16)
end

for c=1:8:144

end

P1=[1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1;1;0;1;1]

P2 = [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0;]


p=1;
pb=1;

%output=zeros(1,144*2)
%for i=1:140
%    G1=mod((out.simout2(i+4)+out.simout(i+3)+out.simout2(i+0)),2)
%    G2=mod((out.simout2(i+4)+out.simout2(i+2)+out.simout(i+1)+out.simout2(i+0)),2)

 %   if P2(p)==1
  %      output(pb)=G1;
   %     pb=pb+1
    %end
    %p=p+1
    %if p>=13
     %   p=1;
    %end
    %if P2(p)==1
     %   output(pb)=G2;
      %  pb=pb+1;
    %end 
    %p=p+1
    %if p>=13
     %   p=1;
    %end

%end

simin=reshape(transpose(decimalToBinaryVector([69 69 69 69 69],8)),1,[])

P = hex2poly('0xC75');
[H,G] = cyclgen(23, P);
G_P = G(1:12, 1:11);
I_K = eye(12);
G = [I_K G_P P.'];
H = [transpose([G_P P.']) I_K];


InterleavingVector=zeros(367,1);
for i=1:367
    InterleavingVector(i)=mod((45*i+92*i^2),368);
end

RandomizeSequence = [
    "D6", "B5", "E2", "30", "82", "FF", "84", "62", "BA", "4E", ...
    "96", "90", "D8", "98", "DD", "5D", "0C", "C8", "52", "43", ...
    "91", "1D", "F8", "6E", "68", "2F", "35", "DA", "14", "EA", ...
    "CD", "76", "19", "8D", "D5", "80", "D1", "33", "87", "13", ...
    "57", "18", "2D", "29", "78", "C3"];

RandomizeSequence=hexToBinaryVector(RandomizeSequence,8)
RandomizeSequence=transpose(RandomizeSequence)
RandomizeSequence=reshape(RandomizeSequence,1,[])



SBLSF= ["55", "F7"]
SBLSF=hexToBinaryVector(SBLSF,8)
SBLSF=transpose(SBLSF)
SBLSF=double(reshape(SBLSF,1,[]))

SBStream= ["FF", "5D"]
SBStream=hexToBinaryVector(SBStream,8)
SBStream=transpose(SBStream)
SBStream=double(reshape(SBStream,1,[]))

SBPacket= ["75", "FF"]
SBPacket=hexToBinaryVector(SBPacket,8)
SBPacket=transpose(SBPacket)
SBPacket=double(reshape(SBPacket,1,[]))


Preample = [
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77", "77", "77", ...
    "77", "77", "77", "77", "77", "77", "77", "77"
];
Preample=hexToBinaryVector(Preample,8)
Preample=transpose(Preample)
Preample=double(reshape(Preample,1,[]))

EoT = [
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D", "55", "5D", ...
    "55", "5D", "55", "5D", "55", "5D", "55", "5D"
];

EoT=hexToBinaryVector(EoT,8)
EoT=transpose(EoT)
EoT=double(reshape(EoT,1,[]))