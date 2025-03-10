function symbolvector = bintoFSK(x)
symbolvector=zeros(size(x));
j=1;
for i=1:2:length(x)
    sym=binaryVectorToDecimal([x(i) x(i+1)]);
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