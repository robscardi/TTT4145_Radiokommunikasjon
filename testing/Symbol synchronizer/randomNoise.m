function y = randomNoise(dim)
    
    y = zeros(dim,1);
    for i = 1:dim
        y(i) = randi([0 1])*pskmod(randi([0 1],2, 1), 4,pi/4, InputType="bit");
    end
    
end

