function symbol = demod_wrap(Input, OutputType)
%DEMOD : wrapper around demodulation function
%   
    assert(OutputType == "bit" || OutputType == "integer")
    symbol = pskdemod(4,Input, pi/4, "gray", "OutputType",OutputType);
end