function binary=decToArray(x,y,z)
binary=decimalToBinaryVector(x,z);
binary=transpose(binary);
if y==1
    binary=double(reshape(binary,1,[]));
else
    binary=reshape(binary,1,[]);
end
end