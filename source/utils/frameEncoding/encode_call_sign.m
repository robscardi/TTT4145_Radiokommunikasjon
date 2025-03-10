function address = encode_call_sign(Callsign)
    address = uint64(0);
    for i = length(Callsign):-1:1
        p = Callsign(i);
        val = 0; % the default value of the character
        if ("A" <= p && p <= 'Z') 
            val = p - 'A' + 1;
        elseif ('0' <= p && p <= '9') 
            val = p - '0' + 27;
        
        elseif ('-' ==  p ) 
            val = 37;
        elseif ('/' ==  p ) 
            val = 38;
        elseif ('.' ==  p ) 
            val = 39;
        elseif ('a' <= p && p <= 'z') 
            val = p - 'a' + 1;
        end
    end 
        address = uint64(40 * address + val); % increment and add
end