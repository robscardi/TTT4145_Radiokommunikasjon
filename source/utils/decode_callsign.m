function Callsign = decode_callsign(address)
%UNTITLED Summary of this function goes here
%   Detailed explana

Callsign = '';
i = 1;
characters = ' ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 -/.';
while address > 0
    Callsign(i) = characters(mod(address, 40));
    address = address/40;
end

end