function y = QPSKtoFSK(sym)
y = zeros(size(sym));
for j=1:length(sym)
    switch sym
        case -1-i1
            y(j) = -3;
        case -1+i1
            y(j) = -1;
        case 1-1i
            y(j) = 1;
        case 1+1i
            y(j) = 3;
    end
end


end