function symbol = mod_wrap(Input, InputType)
%MODUL : wrapper around modulation function
%   
    assert(InputType == "bit" || InputType == "integer")
    symbol = pskmod(Input,4, pi/4,"bin","InputType",InputType)*sqrt(2);
end