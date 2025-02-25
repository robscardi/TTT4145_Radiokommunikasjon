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

output=zeros(1,144*2)
for i=1:140
    G1=mod((out.simout2(i+4)+out.simout(i+3)+out.simout2(i+0)),2)
    G2=mod((out.simout2(i+4)+out.simout2(i+2)+out.simout(i+1)+out.simout2(i+0)),2)

    if P2(p)==1
        output(pb)=G1;
        pb=pb+1
    end
    p=p+1
    if p>=13
        p=1;
    end
    if P2(p)==1
        output(pb)=G2;
        pb=pb+1;
    end 
    p=p+1
    if p>=13
        p=1;
    end

end

output

test2=out.simout3(6,1:275);

simin=reshape(transpose(decimalToBinaryVector([69 69 69 69 69],8)),1,[])

P = hex2poly('0xC75');
[H,G] = cyclgen(23, P);
G_P = G(1:12, 1:11);
I_K = eye(12);
G = [I_K G_P P.'];
H = [transpose([G_P P.']) I_K];