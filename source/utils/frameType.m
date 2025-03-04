classdef frameType < uint8
    %FRAMETYPE Summary of this class goes here
    %   Detailed explanation goes here
    enumeration
    INVALID(0)
    END(1)
    STARTLSF(2)
    STARTBERT(4)
    LSF(8)
    PACKET(16)
    STREAM(32)
    end
end

