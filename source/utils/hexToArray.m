function hex = hexToArray(x,y)
hex=hexToBinaryVector(x,8);
hex=transpose(hex);
if y==1
    hex=double(reshape(hex,1,[]));
else
    hex=reshape(hex,1,[]);
end
end