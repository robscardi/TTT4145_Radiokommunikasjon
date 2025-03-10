function y = FSKtoQPSK(sym)
y = zeros(size(sym));
for j=1:length(sym)
    switch sym(j)
        case -3
            y(j) = -1-1i;
        case -1
            y(j) = -1+1i;
        case 1
            y(j) = 1-1i;
        case 3
            y(j) = 1+1i;
    end
end
end