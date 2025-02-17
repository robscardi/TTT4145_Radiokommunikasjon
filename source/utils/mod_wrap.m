function symbol = mod_wrap(Input, InputType)
%MODUL : wrapper around modulation function
%   
    assert(InputType == "bit" || InputType == "integer")
    symbol = pskmod(4, Input, pi/4,"gray","InputType",InputType);
end